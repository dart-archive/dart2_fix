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
import 'package:analyzer/src/dart/error/hint_codes.dart';

class DeprecationFixer {
  /**
   * The resource provider used to access the file system.
   */
  final ResourceProvider resourceProvider;

  DeprecationFixer(this.resourceProvider);

  Future<void> fixFiles(List<String> paths) async {
    ContextLocator locator =
        new ContextLocator(resourceProvider: resourceProvider);
    List<AnalysisContext> contexts =
        locator.locateContexts(includedPaths: paths);
    for (AnalysisContext context in contexts) {
      AnalysisSession session = context.currentSession;
      for (String path in context.analyzedFiles()) {
        await _fixFile(await session.getResolvedAst(path));
      }
    }
  }

  bool _applyFix(String content, AnalysisError error) {
    // TODO(brianwilkerson) Implement this.
    return false;
  }

  Future<void> _fixFile(ResolveResult result) async {
    List<AnalysisError> errors = result.errors
        .where((error) => error.errorCode == HintCode.DEPRECATED_MEMBER_USE)
        .toList();
    if (errors.isEmpty) {
      return null;
    }
    // Sort in reverse order so that fixes will be applied from the end of the
    // file to the beginning.
    errors.sort((left, right) => left.offset - right.offset);
    String content = result.content;
    bool hasChanges = false;
    for (var error in errors) {
      if (_applyFix(content, error)) {
        hasChanges = true;
      }
    }
    if (hasChanges) {
      _writeChanges(result.path, content);
    }
  }

  void _writeChanges(String filePath, String content) {
    // TODO(brianwilkerson) Implement this.
  }
}
