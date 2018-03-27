import 'package:dart2_fix/src/dart2_fix.dart' as dart2_fix;
import 'package:test/test.dart';

void main() {
  group('dart2_fix', () {
    test('no args exits ok', () async {
      dart2_fix.ExitResult code = await dart2_fix.main([]);
      expect(code.isOk, true);
    });

    test('unexpected args fail', () async {
      dart2_fix.ExitResult code = await dart2_fix.main(['foo']);
      expect(code.isOk, false);
      expect(code.isOk, isNotNull);
    });
  });
}
