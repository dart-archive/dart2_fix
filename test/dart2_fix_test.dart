// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dart2_fix/src/dart_fix.dart';
import 'package:dart2_fix/src/model.dart';
import 'package:test/test.dart';

void main() {
  group('dart2_fix', () {
    test('no args exits ok', () async {
      ExitResult code = await dartFix([]);
      expect(code.isOk, true);
    });

    test('unexpected args fail', () async {
      ExitResult code = await dartFix(['foo']);
      expect(code.isOk, false);
      expect(code.isOk, isNotNull);
    });
  });
}
