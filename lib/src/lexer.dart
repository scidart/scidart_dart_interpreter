import 'package:scidart_dart_interpreter/src/token.dart';

class Lexer {
  int _pos = 0;
  final String _text;
  Token _currentToken = Token(TokenType.sof);

  Lexer(this._text);

  bool _isWhiteSpace(String char) {
    return char == ' ';
  }

  bool _isDigit(String char) {
    return double.tryParse(char) != null;
  }

  String _skipWhiteSpace() {
    while(_isWhiteSpace(_text[_pos]) && (_pos < _text.length - 1)) {
      _pos++;
    }

    return _text[_pos];
  }

  String _getAllNumbers() {
    var number = '';

    for(;;) {
      if (_pos < _text.length && _isDigit(_text[_pos])) {
        number += _text[_pos];
        _pos++;
      } else {
        _pos--;
        break;
      }
    }

    return number;
  }

  Token getCurrentToken() {
    return _currentToken;
  }

  Token getNextToken() {
    if (_pos >= _text.length) {
      _currentToken = Token(TokenType.eof);
    } else {
      var currentChar = _text[_pos];

      if (_isWhiteSpace(currentChar)) {
        currentChar = _skipWhiteSpace();
      }

      if (_isDigit(currentChar)) {
        _currentToken = Token(TokenType.integer, value: _getAllNumbers());
      } else if (Token.stringSymbolToToken[currentChar] != null) {
        _currentToken = Token.stringSymbolToToken[currentChar]!;
      } else if (_isWhiteSpace(currentChar) && (_pos == _text.length - 1)) {
        _currentToken = Token(TokenType.eof);
      } else {
        throw Exception('Error parsing the code at positon: $_pos , char: ${_text[_pos]}');
      }

      _pos++;
    }

    return _currentToken;
  }
}