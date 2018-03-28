// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:path/path.dart' as p;

/// An analysis issue - either an error, or a deprecation issue.
class Issue {
  /// The message of the issue.
  final String message;

  /// The severity of the issue - used to display to the user.
  final String severity;

  // The file path of the issue.
  final String path;

  /// The source line the issue is on.
  final int line;

  /// The offset of the issue from the start of the file.
  final int offset;

  /// The length of the issue in chars.
  final int length;

  /// The full contents of the file.
  final String contents;

  Issue(this.message, this.severity, this.path, this.line, this.offset,
      this.length, this.contents);

  String get matchingSource => contents.substring(offset, offset + length);

  String get shortPath => p.relative(path);

  String get shortMessage => message.endsWith('.')
      ? message.substring(0, message.length - 1)
      : message;

  String toString() => '$severity: $message';
}

/// Return the results of a call to DeprecationLocator.locateIssues().
///
/// This is a tuple so that we can return both analysis errors and deprecation
/// issues.
class DeprecationResults {
  final List<Issue> errors;
  final List<Issue> deprecations;

  DeprecationResults(this.errors, this.deprecations);
}

/// The exit status of the application.
class ExitResult {
  static final ExitResult ok = new ExitResult(0);

  final int result;
  final String errorMessage;

  ExitResult(this.result, [this.errorMessage]);

  bool get isOk => result == 0;

  String toString() => result.toString();
}
