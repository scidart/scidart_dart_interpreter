import 'package:scidart_dart_interpreter/src/petitparser/interpreter.dart';
import 'package:test/test.dart';

void main() {
  group('Simple operations dart', () {
    var interpreter = Interpreter();

    test('var i = 1 + 2 * 3;', () {
      var res = interpreter.process('var i = 1 + 2 * 3;');
      print(res);
      expect(res, 0);
    });

    test('main() {', () {
      var res = interpreter.process('''
void main() {
  print("test");
}  
 ''');
      print(res);
      expect(res, 0);
    });
  });
}