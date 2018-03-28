// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dart2_fix/src/model.dart';

/// Dart 2.0 deprecations.
///
/// In the future, we should drive this via improved deprecation annotations.
final Map<String, String> _textReplacements = {
  // dart:async
  'Zone.ROOT': 'Zone.root',

  // dart:convert
  'ASCII': 'ascii',
  'BASE64': 'base64',
  'BASE64URL': 'base64Url',
  'HTML_ESCAPE': 'htmlEscape',
  'UNKOWN': 'unknown',
  'ATTRIBUTE': 'attribute',
  'SQ_ATTRIBUTE': 'sqAttribute',
  'ELEMENT': 'element',
  'JSON': 'json',
  'LATIN1': 'latin1',
  'UNICODE_REPLACEMENT_CHARACTER_RUNE': 'unicodeReplacementCharacterRune',
  'UNICODE_BOM_CHARACTER_RUNE': 'unicodeBomCharacterRune',
  'UTF8': 'utf8',

  // dart:core
  'DateTime.MONDAY': 'DateTime.monday',
  'DateTime.TUESDAY': 'DateTime.tuesday',
  'DateTime.WEDNESDAY': 'DateTime.wednesday',
  'DateTime.THURSDAY': 'DateTime.thursday',
  'DateTime.FRIDAY': 'DateTime.friday',
  'DateTime.SATURDAY': 'DateTime.saturday',
  'DateTime.SUNDAY': 'DateTime.sunday',
  'DateTime.DAYS_PER_WEEK': 'DateTime.daysPerWeek',
  'DateTime.JANUARY': 'DateTime.january',
  'DateTime.FEBRUARY': 'DateTime.february',
  'DateTime.MARCH': 'DateTime.march',
  'DateTime.APRIL': 'DateTime.april',
  'DateTime.MAY': 'DateTime.may',
  'DateTime.JUNE': 'DateTime.june',
  'DateTime.JULY': 'DateTime.july',
  'DateTime.AUGUSR': 'DateTime.august',
  'DateTime.SEPTEMBER': 'DateTime.september',
  'DateTime.OCTOBER': 'DateTime.october',
  'DateTime.NOVEMBER': 'DateTime.november',
  'DateTime.DECEMBER': 'DateTime.december',
  'DateTime.MONTHS_PER_YEAR': 'DateTime.monthsPerYear',

  'double.NAN': 'DateTime.nan',
  'double.INFINITY': 'DateTime.infinity',
  'double.NEGATIVE_INFINITY': 'DateTime.negativeInfinity',
  'double.MIN_POSITIVE': 'DateTime.minPositive',
  'double.MAX_FINITE': 'DateTime.maxFinite',

  'Duration.MICROSECONDS_PER_MILLISECOND':
      'Duration.microsecondsPerMillisecond',
  'Duration.MILLISECONDS_PER_SECOND': 'Duration.millisecondsPerSecond',
  'Duration.SECONDS_PER_MINUTE': 'Duration.secondsPerMinute',
  'Duration.MINUTES_PER_HOUR': 'Duration.minutesPerHour',

  'Duration.HOURS_PER_DAY': 'Duration.hoursPerDay',
  'Duration.MICROSECONDS_PER_SECOND': 'Duration.microsecondsPerSecond',
  'Duration.MICROSECONDS_PER_MINUTE': 'Duration.microsecondsPerMinute',
  'Duration.MICROSECONDS_PER_HOUR': 'Duration.microsecondsPerHour',

  'Duration.MICROSECONDS_PER_DAY': 'Duration.millisecondsPerMinute',
  'Duration.MILLISECONDS_PER_MINUTE': 'Duration.millisecondsPerMinute',
  'Duration.MILLISECONDS_PER_HOUR': 'Duration.millisecondsPerHour',
  'Duration.MILLISECONDS_PER_DAY': 'Duration.millisecondsPerDay',

  'Duration.SECONDS_PER_HOUR': 'Duration.secondsPerHour',
  'Duration.SECONDS_PER_DAY': 'Duration.secondsPerDay',
  'Duration.MINUTES_PER_DAY': 'Duration.minutesPerDay',
  'Duration.ZERO': 'Duration.zero',

  // dart:isolate
  'Isolate.IMMEDIATE': 'Isolate.immediate',
  'Isolate.BEFORE_NEXT_EVENT': 'Isolate.beforeNextEvent',

  // dart:math
  'E': 'e',
  'LN10': 'ln10',
  'LN2': 'ln2',
  'LOG2E': 'log2e',
  'LOG10E': 'log10e',
  'PI': 'pi',
  'SQRT1_2': 'sqrt1_2',
  'SQRT2': 'sqrt2',

  // dart:typed_data
  'Endianness.BIG_ENDIAN': 'Endian.big',
  'Endianness.LITTLE_ENDIAN': 'Endian.little',
  'Endianness.HOST_ENDIAN': 'Endian.host',
  'Int8List.BYTES_PER_ELEMENT': 'Int8List.bytesPerElement',
  // and, other (long tail) dart:typed_data renames omitted
};

/// A class that can look up the correct change to perform for a given issue.
class ChangeManager {
  static ChangeManager create() {
    return new ChangeManager._(_textReplacements);
  }

  final Map<String, String> textReplacements;

  Set<String> keys;

  ChangeManager._(this.textReplacements) {
    keys = new Set.from(textReplacements.keys.map((key) =>
        key.indexOf('.') != -1 ? key.substring(key.indexOf('.') + 1) : key));
  }

  /// Given an analysis issue, look up the correct change. Returns `null` if
  /// there is no matching change.
  Change getChangeFor(Issue issue) {
    if (!keys.contains(issue.matchingSource)) {
      return null;
    }

    String matchingSource = issue.matchingSource;
    String suffixFragment = '.${matchingSource}';
    for (String key in _textReplacements.keys) {
      if (key == matchingSource) {
        return new TextReplaceChange(
            issue, issue.offset, key, textReplacements[key]);
      } else if (key.endsWith(suffixFragment)) {
        // Check to see if we find the full key.
        int offset = issue.offset - key.length + suffixFragment.length - 1;
        if (offset >= 0 &&
            issue.contents.substring(offset, offset + key.length) == key) {
          return new TextReplaceChange(
              issue, offset, key, textReplacements[key]);
        }
      }
    }

    return null;
  }
}

/// A description of a source change - the type of the change, the location it
/// acts on, and how to perform the change.
abstract class Change implements Comparable<Change> {
  /// A user facing description of the change.
  String get describe;

  /// The offset of the change from the start of the file; used for ordering
  /// purposes.
  int get offset;

  /// The source line of the change - used to display to the user.
  int get line;

  /// Perform the change operation on the given source and return the changed
  /// results.
  String applyTo(String contents);

  int compareTo(Change other) => offset - other.offset;
}

/// An implementation of a Change that is backed by an analysis issue.
class TextReplaceChange extends Change {
  final Issue issue;
  final int offset;
  final String original;
  final String replacement;

  TextReplaceChange(this.issue, this.offset, this.original, this.replacement);

  String get describe => '$original => $replacement';

  int get line => issue.line;

  String applyTo(String contents) {
    return contents.substring(0, offset) +
        replacement +
        contents.substring(offset + original.length);
  }
}
