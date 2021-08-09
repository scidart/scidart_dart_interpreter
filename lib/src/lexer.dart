import 'package:scidart_dart_interpreter/src/token.dart';

class Lexer {
  int _pos = 0;
  final String _text;
  Token _currentToken = Token(TokenType.sof);

  Lexer(this._text);

  bool _isCompoundSymbol(String currentChar) {
    if (_pos + 1 == _text.length) {
      return false;
    }

    var firstPart = Token.stringCompoundSymbolToToken[currentChar];
    var secondPart = Token.stringCompoundSymbolToToken[_text[_pos + 1]];

    return firstPart != null &&
        secondPart != null &&
        firstPart.type == secondPart.type;
  }

  bool _isWhiteSpaceOrNewLine(String char) {
    return char == ' ' || char == '\n';
  }

  bool _isAlpha(String char) {
    // https://stackoverflow.com/a/55768254/6846888
    return char.contains(RegExp(r'[a-zA-Z]'));
  }

  bool _isAlphanum(String char) {
    return char.contains(RegExp(r'[a-zA-Z0-9]'));
  }

  bool _isDigit(String char) {
    return double.tryParse(char) != null;
  }

  Token _id() {
    var result = '';
    while(_isAlphanum(_text[_pos]) && (_pos < _text.length - 1)) {
      result += _text[_pos];
      _pos++;
    }
    _pos--;

    var token;
    if (Token.reservedKeywordsStringToToken[result] != null) {
      token = Token.reservedKeywordsStringToToken[result];
    } else {
      token = Token(TokenType.id, value: result);
    }

    return token;
  }

  Token _getCompoundSymbol() {
    var token = Token.stringCompoundSymbolToToken[_text[_pos]] ?? Token(TokenType.eof);
    while (Token.stringCompoundSymbolToToken[_text[_pos]] != null) {
      _pos++;
    }

    return token;
  }

  String _skipWhiteSpace() {
    while(_isWhiteSpaceOrNewLine(_text[_pos]) && (_pos < _text.length - 1)) {
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

      if (_isWhiteSpaceOrNewLine(currentChar)) {
        currentChar = _skipWhiteSpace();
      }

      if (_isAlpha(currentChar)) {
        _currentToken = _id();
      } else if (_isDigit(currentChar)) {
        _currentToken = Token(TokenType.integer, value: _getAllNumbers());
      } else if (_isCompoundSymbol(currentChar)) {
        _currentToken = _getCompoundSymbol();
      } else if (Token.stringSymbolToToken[currentChar] != null) {
        _currentToken = Token.stringSymbolToToken[currentChar]!;
      } else if (_isWhiteSpaceOrNewLine(currentChar) && (_pos == _text.length - 1)) {
        _currentToken = Token(TokenType.eof);
      } else {
        throw Exception('Error parsing the code at positon: $_pos , char: ${_text[_pos]}');
      }

      _pos++;
    }

    return _currentToken;
  }
}