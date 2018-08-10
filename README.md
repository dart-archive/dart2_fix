[![Build Status](https://travis-ci.org/dart-lang/dart2_fix.svg?branch=master)](https://travis-ci.org/dart-lang/dart2_fix)

A tool to migrate API usage to Dart 2.

**Note: This tool needs to be run on a version of the Dart SDK that contains the deprecated annotations (a pre- `2.0.0-dev.68.0` SDK).**

### What does it do?

`dart2_fix` is a command line utility that can automatically migrate some Dart 1 API usages in your
source code to Dart 2 ones. Currently, it focuses on updating deprecated constant names; for example:
- update `dart:convert`'s `UTF8` to `utf8`
- update `dart:core`'s `Duration.ZERO` to `Duration.zero`
- update `dart:math`'s `PI` to `pi`

For more information about preparing your code for Dart 2, please see the
[Dart 2 migration guide](http://www.dartlang.org/dart-2).

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

### Will this make all of my code Dart 2 compliant?

No.  Currently this only fixes the renaming of various deprecated constant
names.  Some of the less uniform constant renamings are not handled by this
tool. For example `Endianness.BIG_ENDIAN` has been renamed to `Endian.big` but
this will not be caught.  After running this tool, remaining issues can be found
by running the dart analyzer (or flutter analyze) and fixing any deprecation
warnings.

### I'm getting new static (or runtime errors) after running dart2_fix, what went wrong?

This tool can't catch conflicts between the new constant names and any fields or
local variables that you might have in scope.  If you get new analysis warnings
or runtime failures after running this tool, check to see whether one of the
changes made has caused a naming conflict with something else in scope.  The
most common cause of this is having a local variable named `json` in a scope
where `JSON.decode` gets renamed to `json.decode`.  To help with fixing these
kinds of conflicts, the following top level members have been added to
`dart:convert`: `jsonDecode`, `jsonEncode`, `base64Decode`, `base64Encode`, and
`base64UrlEncode`.  These top level members are equivalent to `json.decode`,
`json.decode`, etc, and can be used to avoid naming conflicts where required.


### Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/dart-lang/dart2_fix/issues
