import 'package:scidart_dart_interpreter/src/token.dart';

class Lexer {
  int pos = 0;
  String text;

  Lexer(this.text);

  bool _isWhiteSpace(String char) {
    return char == ' ';
  }

  bool _isDigit(String char) {
    return double.tryParse(char) != null;
  }

  String _skipWhiteSpace() {
    while(_isWhiteSpace(text[pos]) && (pos < text.length - 1)) {
      pos++;
    }

    return text[pos];
  }

  String _getAllNumbers() {
    var number = '';

    for(;;) {
      if (pos < text.length && _isDigit(text[pos])) {
        number += text[pos];
        pos++;
      } else {
        pos--;
        break;
      }
    }

    return number;
  }

  Token getNextToken() {
    if (pos >= text.length) {
      return Token(TokenType.eof);
    } else {
      var currentChar = text[pos];
      Token returnPosToken;

      if (_isWhiteSpace(currentChar)) {
        currentChar = _skipWhiteSpace();
      }

      if (_isDigit(currentChar)) {
        returnPosToken = Token(TokenType.integer, value: _getAllNumbers());
      } else if (Token.stringSymbolToToken[currentChar] != null) {
        returnPosToken = Token.stringSymbolToToken[currentChar]!;
      } else if (_isWhiteSpace(currentChar) && (pos == text.length - 1)) {
        returnPosToken = Token(TokenType.eof);
      } else {
        throw Exception('Error parsing the code at positon: $pos , char: ${text[pos]}');
      }

      pos++;
      return returnPosToken;
    }
  }
}