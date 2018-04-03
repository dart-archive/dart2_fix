// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:dart2_fix/src/dart_fix.dart';
import 'package:dart2_fix/src/model.dart';

main(List<String> args) async {
  ExitResult result = await dartFix(args);
  if (!result.isOk && result.errorMessage != null) {
    stderr.writeln(result.errorMessage);
  }
  exit(result.result);
}
