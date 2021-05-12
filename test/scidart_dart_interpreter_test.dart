import 'package:scidart_dart_interpreter/scidart_dart_interpreter.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    Awesome? awesome;

    setUp(() {
      awesome = Awesome();
    });

    test('First Test', () {
      expect(awesome?.isAwesome, isTrue);
    });
  });
}
