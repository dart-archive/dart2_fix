import 'dart:io';

import 'package:cli_util/cli_logging.dart';
import 'package:dart2_fix/src/dart_fix.dart';
import 'package:dart2_fix/src/model.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

void main() {
  group('DartFix', () {
    Project project;
    BufferLogger logger;

    setUp(() {
      logger = new BufferLogger();
    });

    tearDown(() {
      project?.delete();
    });

    test('check', () async {
      ExitResult result = await dartFixInternal(
          logger, [new Directory('test/data')],
          performDryRun: true);
      expect(result.result, 0);

      String out = logger.stdOutput.toString();
      expect(out, contains('line 6 - PI => pi'));
      expect(out, contains('line 7 - JSON => json'));
      expect(out, contains('line 8 - Duration.ZERO => Duration.zero'));
      expect(out, contains('line 9 - double.INFINITY => double.infinity'));
      expect(out, contains('line 10 - DateTime.AUGUST => DateTime.august'));

      expect(out, contains('line 11 - SYSTEM_ENCODING => systemEncoding'));
      expect(out, contains('line 12 - ZLIB => zlib'));
      expect(out, contains('line 13 - GZIP => gzip'));
      expect(
        out,
        contains(
            'line 14 - FileSystemEntityType.DIRECTORY => FileSystemEntityType.directory'),
      );
      expect(
        out,
        contains('line 15 - ProcessSignal.SIGINT => ProcessSignal.sigint'),
      );
      expect(
        out,
        contains('line 16 - StdioType.TERMINAL => StdioType.terminal'),
      );

      expect(
        out,
        contains(
            'line 17 - HttpStatus.CONTINUE => HttpStatus.continue_')
      );
      expect(
        out,
        contains(
            'line 18 - HttpStatus.NETWORK_CONNECT_TIMEOUT_ERROR => HttpStatus.networkConnectTimeoutError')
      );
      expect(
        out,
        contains(
            'line 19 - HttpHeaders.ACCEPT => HttpHeaders.accept')
      );
      expect(
        out,
        contains(
            'line 20 - HttpHeaders.REQUEST_HEADERS => HttpHeaders.requestHeaders')
      );
      expect(
        out,
        contains(
            'line 21 - ContentType.JSON => ContentType.json')
      );
      expect(
        out,
        contains(
            'line 22 - HttpClient.DEFAULT_HTTPS_PORT => HttpClient.defaultHttpsPort')
      );
      expect(
        out,
        contains(
            'line 23 - WebSocketStatus.NORMAL_CLOSURE => WebSocketStatus.normalClosure')
      );
      expect(
        out,
        contains(
            'line 24 - WebSocket.CLOSED => WebSocket.closed')
      );

      expect(out, contains('Found 19 fixes'));
    });

    test('JSON.encode', () async {
      project = Project.createProject('''
import 'dart:convert';

void main() {
  String str = JSON.encode({});
  dynamic data = JSON.decode(str);
  print(data);

  String encoded = BASE64.encode([1, 2, 3]);
  List decoded = BASE64.decode(encoded);
  print(decoded);
}
''');

      ExitResult result = await dartFixInternal(logger, [project.projectDir],
          performDryRun: false);
      expect(result.result, 0);

      expect(logger.stdOutput.toString(), contains('Applied 4 fixes'));

      expect(project.getMainSource(), '''
import 'dart:convert';

void main() {
  String str = jsonEncode({});
  dynamic data = jsonDecode(str);
  print(data);

  String encoded = base64Encode([1, 2, 3]);
  List decoded = base64Decode(encoded);
  print(decoded);
}
''');
    });

    test('proxy', () async {
      project = Project.createProject('''
@proxy
String foo = 'foo';
void main() { print(foo); }
''');

      ExitResult result = await dartFixInternal(logger, [project.projectDir],
          performDryRun: false);
      expect(result.result, 0);

      expect(logger.stdOutput.toString(), contains('Applied 1 fix'));

      expect(project.getMainSource(), '''

String foo = 'foo';
void main() { print(foo); }
''');
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

class Project {
  Directory projectDir;

  static Project createProject(String mainSource) {
    Directory dir = Directory.systemTemp.createTempSync('dart2fix');

    File mainFile = new File(path.join(dir.path, 'lib', 'main.dart'));
    mainFile.parent.createSync(recursive: true);
    mainFile.writeAsStringSync(mainSource);

    File packagesFile = new File(path.join(dir.path, '.packages'));
    packagesFile.writeAsStringSync('');

    return new Project(dir);
  }

  Project(this.projectDir);

  String getMainSource() {
    return new File(path.join(projectDir.path, 'lib', 'main.dart'))
        .readAsStringSync();
  }

  void delete() {
    projectDir.deleteSync(recursive: true);
  }
}
