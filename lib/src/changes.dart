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
  'DateTime.AUGUST': 'DateTime.august',
  'DateTime.SEPTEMBER': 'DateTime.september',
  'DateTime.OCTOBER': 'DateTime.october',
  'DateTime.NOVEMBER': 'DateTime.november',
  'DateTime.DECEMBER': 'DateTime.december',
  'DateTime.MONTHS_PER_YEAR': 'DateTime.monthsPerYear',

  'double.NAN': 'double.nan',
  'double.INFINITY': 'double.infinity',
  'double.NEGATIVE_INFINITY': 'double.negativeInfinity',
  'double.MIN_POSITIVE': 'double.minPositive',
  'double.MAX_FINITE': 'double.maxFinite',

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

  // dart:io/data_transformer.dart
  'ZLIB': 'zlib',
  'GZIP': 'gzip',
  'ZLibOption.MIN_WINDOW_BITS': 'ZLibOption.minWindowBits',
  'ZLibOption.MAX_WINDOW_BITS': 'ZLibOption.maxWindowBits',
  'ZLibOption.DEFAULT_WINDOW_BITS': 'ZLibOption.defaultWindowBits',
  'ZLibOption.MIN_LEVEL': 'ZLibOption.minLevel',
  'ZLibOption.MAX_LEVEL': 'ZLibOption.maxLevel',
  'ZLibOption.DEFAULT_LEVEL': 'ZLibOption.defaultLevel',
  'ZLibOption.MIN_MEM_LEVEL': 'ZLibOption.minMemLevel',
  'ZLibOption.MAX_MEM_LEVEL': 'ZLibOption.maxMemLevel',
  'ZLibOption.DEFAULT_MEM_LEVEL': 'ZLibOption.defaultMemLevel',
  'ZLibOption.STRATEGY_FILTERED': 'ZLibOption.strategyFiltered',
  'ZLibOption.STRATEGY_HUFFMAN_ONLY': 'ZLibOption.strategyHuffmanOnly',
  'ZLibOption.STRATEGY_RLE': 'ZLibOption.strategyRle',
  'ZLibOption.STRATEGY_FIXED': 'ZLibOption.strategyFixed',
  'ZLibOption.STRATEGY_DEFAULT': 'ZLibOption.strategyDefault',

  // dart:io/file.dart
  'FileMode.READ': 'FileMode.read',
  'FileMode.WRITE': 'FileMode.write',
  'FileMode.APPEND': 'FileMode.append',
  'FileMode.WRITE_ONLY': 'FileMode.writeOnly',
  'FileMode.WRITE_ONLY_APPEND': 'FileMode.writeOnlyAppend',
  'FileLock.SHARED': 'FileLock.shared',
  'FileLock.EXCLUSIVE': 'FileLock.exclusive',
  'FileLock.BLOCKING_SHARED': 'FileLock.blockingShared',
  'FileLock.BLOCKING_EXCLUSIVE': 'FileLock.blockingExclusive',

  // dart:io/file_system_entity.dart
  'FileSystemEntityType.FILE': 'FileSystemEntityType.file',
  'FileSystemEntityType.DIRECTORY': 'FileSystemEntityType.directory',
  'FileSystemEntityType.LINK': 'FileSystemEntityType.link',
  'FileSystemEntityType.NOT_FOUND': 'FileSystemEntityType.notFound',
  'FileSystemEvent.CREATE': 'FileSystemEvent.create',
  'FileSystemEvent.MODIFY': 'FileSystemEvent.modify',
  'FileSystemEvent.DELETE': 'FileSystemEvent.delete',
  'FileSystemEvent.MOVE': 'FileSystemEvent.move',
  'FileSystemEvent.ALL': 'FileSystemEvent.all',

  // dart:io/process.dart
  'ProcessStartMode.NORMAL': 'ProcessStartMode.normal',
  'ProcessStartMode.INHERIT_STDIO': 'ProcessStartMode.inheritStdio',
  'ProcessStartMode.DETACHED': 'ProcessStartMode.detached',
  'ProcessStartMode.DETACHED_WITH_STDIO': 'ProcessStartMode.detachedWithStdio',
  'ProcessSignal.SIGHUP': 'ProcessSignal.sighup',
  'ProcessSignal.SIGINT': 'ProcessSignal.sigint',
  'ProcessSignal.SIGQUIT': 'ProcessSignal.sigquit',
  'ProcessSignal.SIGILL': 'ProcessSignal.sigill',
  'ProcessSignal.SIGTRAP': 'ProcessSignal.sigtrap',
  'ProcessSignal.SIGABRT': 'ProcessSignal.sigabrt',
  'ProcessSignal.SIGBUS': 'ProcessSignal.sigbus',
  'ProcessSignal.SIGFPE': 'ProcessSignal.sigfpe',
  'ProcessSignal.SIGKILL': 'ProcessSignal.sigkill',
  'ProcessSignal.SIGUSR1': 'ProcessSignal.sigusr1',
  'ProcessSignal.SIGSEGV': 'ProcessSignal.sigsegv',
  'ProcessSignal.SIGUSR2': 'ProcessSignal.sigusr2',
  'ProcessSignal.SIGPIPE': 'ProcessSignal.sigpipe',
  'ProcessSignal.SIGALRM': 'ProcessSignal.sigalrm',
  'ProcessSignal.SIGTERM': 'ProcessSignal.sigterm',
  'ProcessSignal.SIGCHLD': 'ProcessSignal.sigchld',
  'ProcessSignal.SIGCONT': 'ProcessSignal.sigcont',
  'ProcessSignal.SIGSTOP': 'ProcessSignal.sigstop',
  'ProcessSignal.SIGTSTP': 'ProcessSignal.sigtstp',
  'ProcessSignal.SIGTTIN': 'ProcessSignal.sigttin',
  'ProcessSignal.SIGTTOU': 'ProcessSignal.sigttou',
  'ProcessSignal.SIGURG': 'ProcessSignal.sigurg',
  'ProcessSignal.SIGXCPU': 'ProcessSignal.sigxcpu',
  'ProcessSignal.SIGXFSZ': 'ProcessSignal.sigxfsz',
  'ProcessSignal.SIGVTALRM': 'ProcessSignal.sigvtalrm',
  'ProcessSignal.SIGPROF': 'ProcessSignal.sigprof',
  'ProcessSignal.SIGWINCH': 'ProcessSignal.sigwinch',
  'ProcessSignal.SIGPOLL': 'ProcessSignal.sigpoll',
  'ProcessSignal.SIGSYS': 'ProcessSignal.sigsys',

  // dart:io/socket.dart
  'InternetAddressType.TERMINAL': 'InternetAddressType.terminal',
  'InternetAddressType.IP_V4': 'InternetAddressType.IPv4',
  'InternetAddressType.IP_V6': 'InternetAddressType.IPv6',
  'InternetAddressType.ANY': 'InternetAddressType.any',
  'InternetAddress.LOOPBACK_IP_V4': 'InternetAddress.loopbackIPv4',
  'InternetAddress.LOOPBACK_IP_V6': 'InternetAddress.loopbackIPv6',
  'InternetAddress.ANY_IP_V4': 'InternetAddress.anyIPv4',
  'InternetAddress.ANY_IP_V6': 'InternetAddress.anyIPv6',
  'SocketDirection.RECEIVE': 'SocketDirection.receive',
  'SocketDirection.SEND': 'SocketDirection.send',
  'SocketDirection.BOTH': 'SocketDirection.both',
  'SocketOption.TCP_NODELAY': 'SocketOption.tcpNoDelay',
  'RawSocketEvent.READ': 'RawSocketEvent.read',
  'RawSocketEvent.WRITE': 'RawSocketEvent.write',
  'RawSocketEvent.READ_CLOSED': 'RawSocketEvent.readClosed',
  'RawSocketEvent.CLOSED': 'RawSocketEvent.closed',

  // dart:io/stdio.dart
  'StdioType.TERMINAL': 'StdioType.terminal',
  'StdioType.PIPE': 'StdioType.pipe',
  'StdioType.FILE': 'StdioType.file',
  'StdioType.OTHER': 'StdioType.other',

  // dart:io/string_transformer.dart
  'SYSTEM_ENCODING': 'systemEncoding',
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
