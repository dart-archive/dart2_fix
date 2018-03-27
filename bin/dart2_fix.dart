// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:dart2_fix/src/dart2_fix.dart' as dart2_fix;

main(List<String> args) async {
  dart2_fix.ExitCode result = await dart2_fix.main(args);
  if (!result.isOk && result.errorMessage != null) {
    stderr.writeln(result.errorMessage);
  }
  exit(result.statusCode);
}
