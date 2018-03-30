// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:analysis_server_lib/analysis_server_lib.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:dart2_fix/src/model.dart';
import 'package:path/path.dart' as path;

class DeprecationLocator {
  DeprecationLocator();

  Future<DeprecationResults> locateIssues(
      List<String> directories, Logger logger) async {
    AnalysisServer client = await AnalysisServer.create(
        //vmArgs: ['--preview-dart-2'],
        );

    Completer completer = new Completer();
    client.processCompleter.future.then((int code) {
      if (!completer.isCompleted) {
        completer.completeError('analysis exited early (exit code $code)');
      }
    });

    await client.server.onConnected.first.timeout(new Duration(seconds: 10));

    bool hadServerError = false;

    // handle errors
    client.server.onError.listen((ServerError error) {
      StackTrace trace = error.stackTrace == null
          ? null
          : new StackTrace.fromString(error.stackTrace);

      logger.stderr('${error}');
      logger.stderr('${trace.toString().trim()}');

      hadServerError = true;
    });

    client.server.setSubscriptions(['STATUS']);
    client.server.onStatus.listen((ServerStatus status) {
      if (status.analysis == null) return;

      if (!status.analysis.isAnalyzing) {
        // notify finished
        if (!completer.isCompleted) {
          completer.complete(true);
        }
        client.dispose();
      }
    });

    Map<String, List<AnalysisError>> errorMap = new Map();
    client.analysis.onErrors.listen((AnalysisErrors e) {
      errorMap[e.file] = e.errors;
    });

    client.analysis.setAnalysisRoots(
        directories.map((dir) => path.canonicalize(dir)).toList(), []);

    // wait for finish
    await completer.future;

    List<String> sources = errorMap.keys.toList();
    List<AnalysisError> errors = sources
        .map((String key) => errorMap[key])
        .fold([], (List a, List b) {
          a.addAll(b);
          return a;
        })
        .toList()
        .cast<AnalysisError>();

    DeprecationResults results = new DeprecationResults([], []);

    SourceLoader sourceLoader = new SourceLoader();

    for (AnalysisError error in errors) {
      if (error.severity == 'ERROR') {
        results.errors.add(_errorToIssue(error, sourceLoader));
      } else if (error.code == 'deprecated_member_use') {
        results.deprecations.add(_errorToIssue(error, sourceLoader));
      }
    }

    return results;
  }

  Issue _errorToIssue(AnalysisError error, SourceLoader sourceLoader) {
    return new Issue(
        error.message,
        error.severity,
        error.location.file,
        error.location.startLine,
        error.location.offset,
        error.location.length,
        sourceLoader.loadSource(error.location.file));
  }
}

class SourceLoader {
  Map cache = {};

  SourceLoader();

  String loadSource(String filePath) {
    return cache.putIfAbsent(
        filePath, () => new File(filePath).readAsStringSync());
  }
}
