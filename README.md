[![Build Status](https://travis-ci.org/dart-lang/dart2_fix.svg?branch=master)](https://travis-ci.org/dart-lang/dart2_fix)

A tool to migrate API usage to Dart 2.

### What does it do?

`dart2_fix` is a command line utility that can automatically migrate some Dart 1 API usages in your
source code to Dart 2 ones. Currently, it focuses on updating deprecated constant names; for example:
- update `dart:convert`'s `UTF8` to `utf8`
- update `dart:core`'s `Duration.ZERO` to `Duration.zero`
- update `dart:math`'s `PI` to `pi

### How do I use it?

To install, run `pub global activate dart2_fix`. Then, from your project directory, run:

`pub global run dart2_fix`

When run without any arguments, it will check your project, but will not make changes; it'll
indicate what would be changed if asked to make modifications. For example:

```
test/test/runner/load_suite_test.dart
  line 56 • Duration.ZERO => Duration.zero
  line 60 • Duration.ZERO => Duration.zero
  line 86 • Duration.ZERO => Duration.zero

test/tool/host.dart
  line 169 • JSON => json
  line 173 • JSON => json

Found 5 fixes in 2.3s.

To apply these fixes, run again using the --apply argument.
```

To actually modify your project source code, run with the `--apply` argument (`pub global run dart2_fix --apply`):

```
Updating test...

test/test/runner/load_suite_test.dart
  3 fixes applied for Duration.ZERO => Duration.zero

test/tool/host.dart
  2 fixes applied for JSON => json

Applied 5 fixes in 1.9s.
```

### What about Flutter code?

To run this tool on Flutter code, use:

```
flutter packages pub global activate dart2_fix
```

then - to check your code - run:

```
flutter packages pub global run dart2_fix
```

and to apply fixes, run:

```
flutter packages pub global run dart2_fix --apply
```

### Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/dart-lang/dart2_fix/issues
