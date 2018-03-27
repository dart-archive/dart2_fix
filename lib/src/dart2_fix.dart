// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

//import 'package:args/args.dart';

Future<ExitCode> main(List<String> args) async {
  // TODO: implement the UI

  if (args.isNotEmpty) {
    return new ExitCode(1, 'unexpected argument: ${args.first}');
  }

  return ExitCode.ok;
}

class ExitCode {
  static final ExitCode ok = new ExitCode(0);

  final int statusCode;
  final String errorMessage;

  ExitCode(this.statusCode, [this.errorMessage]);

  bool get isOk => statusCode == 0;

  String toString() => statusCode.toString();
}
