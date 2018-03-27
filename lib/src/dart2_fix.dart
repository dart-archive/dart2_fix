// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

//import 'package:args/args.dart';

Future<ExitResult> main(List<String> args) async {
  // TODO: implement the UI

  if (args.isNotEmpty) {
    return new ExitResult(1, 'unexpected argument: ${args.first}');
  }

  return ExitResult.ok;
}

class ExitResult {
  static final ExitResult ok = new ExitResult(0);

  final int result;
  final String errorMessage;

  ExitResult(this.result, [this.errorMessage]);

  bool get isOk => result == 0;

  String toString() => result.toString();
}
