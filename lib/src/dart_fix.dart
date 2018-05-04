// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:dart2_fix/src/changes.dart';
import 'package:dart2_fix/src/deprecation_analysis_server.dart';
import 'package:dart2_fix/src/model.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

final NumberFormat _nf = new NumberFormat('0.0');

Future<ExitResult> dartFix(List<String> args) async {
  ArgParser argParser = new ArgParser();
  argParser.addFlag('help',
      negatable: false, abbr: 'h', help: 'Display usage help.');
  argParser.addFlag('apply',
      abbr: 'w',
      negatable: false,
      help: "Apply the refactoring changes to the project's source files.");
  argParser.addOption('check-package',
      help:
          'Retrieve the source for the given hosted package and run checks on '
          'it\n(this command is not typically run by users).',
      valueHelp: 'package name');
  argParser.addFlag('verbose',
      negatable: false, help: 'Print verbose logging information.');
  argParser.addFlag('color',
      help: 'Use ansi colors when printing messages.',
      defaultsTo: Ansi.terminalSupportsAnsi);

  ArgResults results;

  try {
    results = argParser.parse(args);

    if (results['help']) {
      _printUsage(argParser);
      return ExitResult.ok;
    }
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    print('');
    _printUsage(argParser);
    return new ExitResult(1);
  }

  List<Directory> dirs = results.rest.isEmpty
      ? [Directory.current]
      : results.rest.map((s) => new Directory(s)).toList();

  for (Directory dir in dirs) {
    if (!dir.existsSync()) {
      return new ExitResult(
          1, "'${dir.path}' does not exist or is not a directory.");
    }
  }

  final bool verbose = results['verbose'];
  Ansi ansi = new Ansi(results.wasParsed('color')
      ? results['color']
      : Ansi.terminalSupportsAnsi);
  Logger logger = verbose
      ? new Logger.verbose(ansi: ansi)
      : new Logger.standard(ansi: ansi);

  final bool performDryRun = !results['apply'];
  final String packageName = results['check-package'];

  if (packageName != null) {
    return await checkPackage(logger, packageName, performDryRun);
  } else {
    return await dartFixInternal(logger, dirs, performDryRun);
  }
}

// public for testing
Future<ExitResult> dartFixInternal(
    Logger logger, List<Directory> dirs, bool performDryRun) async {
  final Ansi ansi = logger.ansi;

  Progress progress;
  if (performDryRun) {
    progress =
        logger.progress('Checking ${dirs.map((d) => d.path).join(', ')}');
  } else {
    progress =
        logger.progress('Updating ${dirs.map((d) => d.path).join(', ')}');
  }

  Stopwatch stopwatch = new Stopwatch()..start();
  DeprecationLocator locator = new DeprecationLocator(logger);
  final DeprecationResults issues =
      await locator.locateIssues(dirs.map((d) => d.path).toList());

  progress.finish();

  logger.stdout('');

  if (issues.errors.isNotEmpty) {
    for (Issue issue in issues.errors) {
      logger.stdout('${issue.severity.toLowerCase()} ${ansi.bullet} ${issue
          .shortPath}:${issue
          .line} ${ansi
          .bullet} ${ansi.emphasized(issue.shortMessage)}');
    }

    logger.stdout('');

    String suffix = performDryRun ? '' : '; no changes applied';

    double seconds = stopwatch.elapsedMilliseconds / 1000.0;
    return new ExitResult(
        1,
        'Found ${issues.errors.length} analysis ${_pluralize(
            issues.errors.length, 'error', 'errors')}$suffix (in ${_nf.format(
            seconds)}s).');
  }

  ChangeManager changeManager = ChangeManager.create();
  Map<String, List<Change>> changes = {};

  int count = 0;

  for (Issue issue in issues.deprecations) {
    final Change change = changeManager.getChangeFor(issue);
    if (change != null) {
      count++;
      changes.putIfAbsent(issue.path, () => []);
      changes[issue.path].add(change);
    }
  }

  if (performDryRun) {
    List<String> paths = changes.keys.toList();
    paths.sort();

    for (String path in paths) {
      logger.stdout(p.relative(path));

      List<Change> fileChanges = changes[path];
      fileChanges.sort();

      for (Change change in fileChanges) {
        logger.stdout('  line ${change.line} ${ansi.bullet} ${ansi.emphasized(
            change.describe)}');
      }

      logger.stdout('');
    }

    double seconds = stopwatch.elapsedMilliseconds / 1000.0;
    logger.stdout('Found ${count} fixes in ${_nf.format(seconds)}s.');
    if (count > 0) {
      logger.stdout('');
      logger.stdout(
          'To apply these fixes, run again using the --apply argument.');
    }
  } else {
    List<String> paths = changes.keys.toList();
    paths.sort();

    for (String path in paths) {
      logger.stdout(p.relative(path));

      List<Change> fileChanges = changes[path];
      fileChanges.sort();

      File file = new File(path);
      String contents = file.readAsStringSync();

      Map<String, int> fixCounts = {};

      for (Change change in fileChanges.reversed) {
        contents = change.applyTo(contents);
        String description = change.describe;
        fixCounts.putIfAbsent(description, () => 0);
        fixCounts[description] = fixCounts[description] + 1;
      }

      file.writeAsStringSync(contents);

      for (String desc in fixCounts.keys) {
        logger.stdout('  ${fixCounts[desc]} ${_pluralize(
            fixCounts[desc], 'fix', 'fixes')} applied for ${ansi.emphasized(
            desc)}');
      }

      logger.stdout('');
    }

    double seconds = stopwatch.elapsedMilliseconds / 1000.0;
    logger
        .stdout('Applied ${count} ${_pluralize(count, 'fix', 'fixes')} in ${_nf
        .format(seconds)}s.');
  }

  return ExitResult.ok;
}

Future<ExitResult> checkPackage(
    Logger logger, String packageName, bool performDryRun) async {
  String jsonData =
      await _uriDownload('https://pub.dartlang.org/api/packages/$packageName/');
  Map json = jsonDecode(jsonData);
  Map pubspec = json['latest']['pubspec'];
  String homepage = pubspec['homepage'];

  if (homepage == null) {
    return new ExitResult(1, 'No homepage definied for package $packageName.');
  }

  Uri homepageUri = Uri.parse(homepage);
  if (homepageUri.host != 'github.com') {
    return new ExitResult(
        1, "Homepage is '$homepage', but we require it to be a github repo.");
  }

  if (homepageUri.path.substring(1).split('/').length > 2) {
    return new ExitResult(
        1,
        'Unsupported homepage reference: $homepage.\n'
        'This tool only supports a homepage reference that points to the root of a repo.');
  }

  Directory dir = new Directory(packageName);
  dir.createSync();

  Progress progress;

  if (performDryRun) {
    progress = logger.progress('Cloning $homepage into $packageName');
    try {
      await gitClone(homepageUri, dir);
    } finally {
      progress.finish();
    }

    progress = logger.progress('Running pub get');
    try {
      await pubGet(dir);
    } finally {
      progress.finish();
    }
  }

  return await dartFixInternal(logger, [dir], performDryRun);
}

Future gitClone(Uri uri, Directory dir) async {
  Process process = await Process.start('git', ['clone', uri.toString(), '.'],
      workingDirectory: dir.path);
  return process.exitCode;
}

Future pubGet(Directory dir) async {
  String pubPath = p.join(p.dirname(Platform.resolvedExecutable), 'pub');
  Process process =
      await Process.start(pubPath, ['get'], workingDirectory: dir.path);
  return process.exitCode;
}

String _pluralize(int count, String singular, String plural) =>
    count == 1 ? singular : plural;

void _printUsage(ArgParser argParser) {
  print('usage: dart2_fix [options...] <directories>');
  print('');
  print(argParser.usage);
}

Future<String> _uriDownload(String uri) async {
  HttpClient client = new HttpClient();
  HttpClientRequest request = await client.getUrl(Uri.parse(uri));
  HttpClientResponse response = await request.close();

  Completer<String> completer = new Completer<String>();
  StringBuffer contents = new StringBuffer();
  response.transform(utf8.decoder).listen((String data) {
    contents.write(data);
  }, onDone: () => completer.complete(contents.toString()));
  return completer.future;
}
