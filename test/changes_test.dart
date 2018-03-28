// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dart2_fix/src/changes.dart';
import 'package:test/test.dart';

void main() {
  group('TextReplaceChange', () {
    test('applyChange', () {
      String from = 'abc def ghi';
      String to = '123 def ghi';
      TextReplaceChange change =
          new TextReplaceChange(null, from.indexOf('abc'), 'abc', '123');
      expect(change.applyTo(from), to);
    });
    test('applyChange', () {
      String from = 'abc def ghi';
      String to = 'abc 123 ghi';
      TextReplaceChange change =
          new TextReplaceChange(null, from.indexOf('def'), 'def', '123');
      expect(change.applyTo(from), to);
    });
    test('applyChange', () {
      String from = 'abc def ghi';
      String to = 'abc def 123';
      TextReplaceChange change =
          new TextReplaceChange(null, from.indexOf('ghi'), 'ghi', '123');
      expect(change.applyTo(from), to);
    });
  });
}
