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

    test('10+10*10', () {
      var res = interpreter?.process('10+10*10');
      print(res);

      expect(res, 110);
    });

    test('10+10/10', () {
      var res = interpreter?.process('10+10/10');
      print(res);

      expect(res, 11);
    });

    test('(10+10)/10', () {
      var res = interpreter?.process('(10+10)/10');
      print(res);

      expect(res, 2);
    });

    test('7 + 3 * (10 / (12 / (3 + 1) - 1))', () {
      var res = interpreter?.process('7 + 3 * (10 / (12 / (3 + 1) - 1))');
      print(res);

      expect(res, 22);
    });

    test('- - 1', () {
      var res = interpreter?.process('- - 1');
      print(res);

      expect(res, 1);
    });

    test('5---2', () {
      var res = interpreter?.process('5---2');
      print(res);

      expect(res, 3);
    });

    test('5---+-3', () {
      var res = interpreter?.process('5---+-3');
      print(res);

      expect(res, 8);
    });

    test('5 - - - + - (3 + 4) - +2', () {
      var res = interpreter?.process('5 - - - + - (3 + 4) - +2');
      print(res);

      expect(res, 10);
    });


    test('BEGIN a := 2; END.', () {
      var res = interpreter?.process('BEGIN a := 2; END.');
      print(res);

      expect(res, 10);
    });

    test('BEGIN BEGIN a := 2; ....', () {
      var res = interpreter?.process('''
BEGIN
  BEGIN
      number := 2;
      a := number;
      b := 10 * a + 10 * number / 4;
      c := a - - b;
  END;
    x := 11;
END.
''');
      print(res);

      expect(res, 0);
    });

    test('PROGRAM Part10; VAR...', () {
      var res = interpreter?.process('''
PROGRAM Part10; {Part10}
VAR
   number     : INTEGER;
   a, b, c, x : INTEGER;
   y          : REAL;

BEGIN {Part10}
   BEGIN
      number := 2;
      a := number;
      b := 10 * a + 10 * number DIV 4;
      c := a - - b
   END;
   x := 11;
   y := 20 / 7 + 3.14;
   { writeln('a = ', a); }
   { writeln('b = ', b); }
   { writeln('c = ', c); }
   { writeln('number = ', number); }
   { writeln('x = ', x); }
   { writeln('y = ', y); }
END.  {Part10}
''');
      print(res);

      expect(res, 0);
    });
  });
}
