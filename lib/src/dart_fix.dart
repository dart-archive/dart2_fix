// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:dart2_fix/src/changes.dart';
import 'package:dart2_fix/src/deprecation_analysis_server.dart';
import 'package:dart2_fix/src/model.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

// TODO: audit and simplify code

final NumberFormat _nf = new NumberFormat('0.0');

Future<ExitResult> dartFix(List<String> args) async {
  ArgParser argParser = new ArgParser();
  argParser.addFlag('help',
      negatable: false, abbr: 'h', help: 'Display usage help.');
  argParser.addFlag('apply',
      abbr: 'w',
      negatable: false,
      help: "Apply the refactoring changes to the project's source files.");
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

  Ansi ansi = new Ansi(results.wasParsed('color')
      ? results['color']
      : Ansi.terminalSupportsAnsi);
  Logger logger = new Logger.standard(ansi: ansi);
  final bool performDryRun = !results['apply'];

  return await dartFixInternal(logger, dirs, performDryRun);
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
  DeprecationLocator locator = new DeprecationLocator();
  final DeprecationResults issues =
      await locator.locateIssues(dirs.map((d) => d.path).toList(), logger);

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

    return new ExitResult(
        1,
        'Found ${issues.errors.length} analysis ${_pluralize(
            issues.errors.length, 'error', 'errors')}$suffix.');
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

String _pluralize(int count, String singular, String plural) =>
    count == 1 ? singular : plural;

void _printUsage(ArgParser argParser) {
  print('usage: dart2_fix [options...] <directories>');
  print('');
  print(argParser.usage);
}
