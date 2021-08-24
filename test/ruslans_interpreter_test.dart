import 'package:scidart_dart_interpreter/src/ruslans/interpreter.dart';
import 'package:test/test.dart';

import 'helpers/helpers.dart';

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

  });

  group('simple program structures', () {
    Interpreter? interpreter;

    setUp(() {
      interpreter = Interpreter();
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
      expect(interpreter?.globalMemory.length, 5);

      expect(res, 0);
    });

  });

  group('variable declarations and comments', () {
    Interpreter? interpreter;

    setUp(() {
      interpreter = Interpreter();
    });

    test('PROGRAM Part10; VAR...', () {
      interpreter?.process('''
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
      expect(interpreter?.globalMemory.length, 6);
    });

    test('PROGRAM NameError1;', () {
      expect(() {
        var res = interpreter?.process('''
PROGRAM NameError1;
VAR
   a : INTEGER;

BEGIN
   a := 2 + b;
END.
''');
        print(res);
      }, throwsException);
    });

    test('PROGRAM NameError2;', () {
      expect(() {
        var res = interpreter?.process('''
PROGRAM NameError2;
VAR
   b : INTEGER;

BEGIN
   b := 1;
   a := b + 2;
END.
''');
        print(res);
      }, throwsException);
    });

    test('PROGRAM Part12;', () {
      interpreter?.process('''
PROGRAM Part12;
VAR
   a : INTEGER;

PROCEDURE P1;
VAR
   b : REAL;
   k : INTEGER;

   PROCEDURE P2;
   VAR
      c, z : INTEGER;
   BEGIN {P2}
      z := 777;
   END;  {P2}

BEGIN {P1}

END;  {P1}

BEGIN {Part12}
   a := 10;
END.  {Part12}
''');
      expect(interpreter?.globalMemory.length, 1);
    });

    test('duplicated symbol error', () {
      expect(() {
        var res = interpreter?.process('''
program SymTab6;
  var x, y : integer;
  var y : real;
  begin
  x := x + y;
end.
''');
        print(res);
      }, throwsException);
    });

    test('not declared symbol error', () {
      expect(() {
        var res = interpreter?.process('''
program SymTab6;
  var x: integer;
  begin
  x := x + y;
end.
''');
        print(res);
      }, throwsException);
    });

    test('not valit type symbol error', () {
      expect(() {
        var res = interpreter?.process('''
program SymTab6;
  var x, y: integer;
  var z: something;
  begin
  x := x + y;
end.
''');
        print(res);
      }, throwsException);
    });
  });

  group('scoped variables', () {
    const directory = './test/reuslans_interpreter_files/';
    Interpreter? interpreter;

    setUp(() {
      interpreter = Interpreter();
    });

    test('global scope', () async {
      var code = '''
program Main;
   var x, y : integer;
begin
   x := x + y;
end.
''';
      interpreter?.process(code);
      await saveTree(interpreter!.genDot, directory + 'scoped_variables_global_scode');
    });

    test('procedure declaration', () async {
      var code = '''
program Main;
   var x, y: real;

   procedure Alpha(a : integer);
      var y : integer;
   begin
      x := a + x + y;
   end;

begin { Main }

end.  { Main }
''';
      interpreter?.process(code);
      await saveTree(interpreter!.genDot, directory + 'scoped_variables_procedure_declaration');
    });
  });
}
