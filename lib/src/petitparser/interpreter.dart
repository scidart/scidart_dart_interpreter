import 'package:scidart_dart_interpreter/src/petitparser/parser.dart';

class Interpreter {
  final DartGrammarDefinition _definition = DartGrammarDefinition();

  int process(String code) {
    final parser = _definition.build();
    final result = parser.parse(code);
    print(result.value);
    return 0;
  }
}