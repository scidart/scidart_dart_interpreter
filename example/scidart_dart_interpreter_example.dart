import 'package:scidart_dart_interpreter/src/ruslans/interpreter.dart';

void main() {
  var interpreter = Interpreter();
  var res = interpreter.process('10+10*10');
  print(res);
}
