import 'package:scidart_dart_interpreter/src/interpreter.dart';
import 'package:test/test.dart';

void main() {
  group('Simple operations test', () {
    Interpreter? interpreter;

    setUp(() {
      interpreter = Interpreter();
    });

    test('1+2', () {
      var res = interpreter?.process('1+2');
      print(res);

      expect(res, 3);
    });

    test('1 +2', () {
      var res = interpreter?.process('1 +2');
      print(res);

      expect(res, 3);
    });

    test('10+2', () {
      var res = interpreter?.process('10+2');
      print(res);

      expect(res, 12);
    });

    test('10 +  2', () {
      var res = interpreter?.process('10 +  2');
      print(res);

      expect(res, 12);
    });

    test('  10 +  2  ', () {
      var res = interpreter?.process('  10 +  2  ');
      print(res);

      expect(res, 12);
    });

    test('10 - 2', () {
      var res = interpreter?.process('10 - 2');
      print(res);

      expect(res, 8);
    });

    test('10 * 2', () {
      var res = interpreter?.process('10 * 2');
      print(res);

      expect(res, 20);
    });

    test('10 / 2', () {
      var res = interpreter?.process('10 / 2');
      print(res);

      expect(res, 5);
    });

    test('10 +', () {
      try {
        var _ = interpreter?.process('10 +');
        expect(true, false);
      } catch(e) {
        expect(true, true);
      }
    });

    test('10+10-10', () {
      var res = interpreter?.process('10+10-10');
      print(res);

      expect(res, 10);
    });

    test('  10 + 10-10  ', () {
      var res = interpreter?.process('  10 + 10-10  ');
      print(res);

      expect(res, 10);
    });

    test('  10 + 10-10 + 1 + 100 + 4', () {
      var res = interpreter?.process('  10 + 10-10 + 1 + 100 + 4');
      print(res);

      expect(res, 115);
    });

    test('1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1', () {
      var res = interpreter?.process('1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1');
      print(res);

      expect(res, 15);
    });
  });
}
