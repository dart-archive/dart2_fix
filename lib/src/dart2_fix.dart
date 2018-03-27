// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:dart2_fix/src/deprecation_fix.dart';

// Duration.ZERO ==> Duration.zero

// checking/updating sdsdf...
//
// main.dart
//   7 changes Duration.ZERO ==> Duration.zero
// foo.dart
//   1 change Duration.BAZ ==> Duration.baz
//   3 changes Duration.ZERO ==> Duration.zero
//
//  37 changes total.

Future<ExitResult> main(List<String> args) async {
  ArgParser argParser = new ArgParser();
  argParser.addFlag('help',
      negatable: false, abbr: 'h', help: 'Display usage help.');
  argParser.addFlag('apply',
      abbr: 'w',
      negatable: false,
      help: "Apply the refactoring changes to the project's source files.");

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

  bool dryRun = !results['apply'];

  // TODO(devoncarew): implement
  print('dryrun: $dryRun over ${dirs}');

  var fixer = new DeprecationFixer(PhysicalResourceProvider.INSTANCE);
  // TODO(brianwilkerson) Compute the paths of the files / directories to be fixed.
  fixer.fixFiles(dirs.map((d) => d.path).toList());

  return ExitResult.ok;
}

void _printUsage(ArgParser argParser) {
  print('usage: dart2_fix [options...] <directories>');
  print('');
  print(argParser.usage);
}

class ExitResult {
  static final ExitResult ok = new ExitResult(0);

  final int result;
  final String errorMessage;

  ExitResult(this.result, [this.errorMessage]);

  bool get isOk => result == 0;

  String toString() => result.toString();
}
