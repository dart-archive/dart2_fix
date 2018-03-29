import 'dart:io';

import 'package:cli_util/cli_logging.dart';
import 'package:dart2_fix/src/dart_fix.dart';
import 'package:dart2_fix/src/model.dart';
import 'package:test/test.dart';

// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

void main() {
  group('DartFix', () {
    test('check ', () async {
      BufferLogger logger = new BufferLogger();

      ExitResult result =
          await dartFixInternal(logger, [new Directory('test/data')], true);
      expect(result.result, 0);

      String out = logger.stdOutput.toString();
      expect(out, contains('line 5 - PI => pi'));
      expect(out, contains('line 6 - JSON => json'));
      expect(out, contains('line 7 - Duration.ZERO => Duration.zero'));
      expect(out, contains('line 8 - double.INFINITY => double.infinity'));
      expect(out, contains('line 9 - DateTime.AUGUST => DateTime.august'));
      expect(out, contains('Found 5 fixes'));
    });
  });
}

class BufferLogger implements Logger {
  StringBuffer stdOutput = new StringBuffer();
  StringBuffer stdError = new StringBuffer();

  BufferLogger() {}

  final Ansi ansi = new TestAnsi();

  void flush() {}

  bool get isVerbose => false;

  Progress progress(String message) {
    return new _SimpleProgress(this, message);
  }

  @override
  void stderr(String message) {
    stdError.writeln(message);
  }

  @override
  void stdout(String message) {
    stdOutput.writeln(message);
  }

  @override
  void trace(String message) {}
}

class _SimpleProgress implements Progress {
  final Logger logger;
  final String message;
  Stopwatch _stopwatch;

  _SimpleProgress(this.logger, this.message) {
    _stopwatch = new Stopwatch()..start();
    logger.stdout('$message...');
  }

  Duration get elapsed => _stopwatch.elapsed;

  void cancel() {}

  void finish({String message, bool showTiming}) {}
}

class TestAnsi extends Ansi {
  TestAnsi() : super(false);

  String get bullet => '-';
}
