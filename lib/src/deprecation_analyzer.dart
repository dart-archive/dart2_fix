// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/context_locator.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/dart/error/hint_codes.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:dart2_fix/src/model.dart';

// TODO(devoncarew): This API doesn't seem to use the driver cache.

class DeprecationLocator {
  /**
   * The resource provider used to access the file system.
   */
  final ResourceProvider resourceProvider;

  DeprecationLocator(this.resourceProvider);

  DeprecationLocator.defaults()
      : resourceProvider = PhysicalResourceProvider.INSTANCE;

  Future<DeprecationResults> locateIssues(List<String> paths) async {
    ContextLocator locator =
        new ContextLocator(resourceProvider: resourceProvider);
    List<AnalysisContext> contexts =
        locator.locateContexts(includedPaths: paths);

    DeprecationResults results = new DeprecationResults([], []);

    for (AnalysisContext context in contexts) {
      AnalysisSession session = context.currentSession;
      // TODO(devoncarew): analyzedFiles() is returning non-Dart files. Either
      // it shouldn't, or session.getResolvedAst() should not try and parse
      // non-Dart files.
      for (String path in context.analyzedFiles()) {
        if (!path.endsWith('.dart')) {
          continue;
        }
        await _locateInFile(results, await session.getResolvedAst(path));
      }
    }

    return results;
  }

  void _locateInFile(DeprecationResults results, ResolveResult result) {
    Iterable<AnalysisError> deprecations = result.errors
        .where((error) => error.errorCode == HintCode.DEPRECATED_MEMBER_USE);
    results.deprecations.addAll(deprecations
        .map((e) => _errorToIssue(result.lineInfo, e, result.content)));

    // TODO(devoncarew): We want ErrorSeverity.ERROR here, but I believe that
    // strong mode error severity remapping is not happening.
    Iterable<AnalysisError> errors = result.errors.where((error) =>
        error.errorCode.errorSeverity.ordinal >= ErrorSeverity.WARNING.ordinal);
    results.errors.addAll(
        errors.map((e) => _errorToIssue(result.lineInfo, e, result.content)));
  }
}

Issue _errorToIssue(LineInfo lineInfo, AnalysisError error, String contents) {
  int line = lineInfo.getLocation(error.offset).lineNumber;

  return new Issue(error.message, error.errorCode.errorSeverity.displayName,
      error.source.fullName, line, error.offset, error.length, contents);
}
