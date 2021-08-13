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

  bool _isWhiteSpace(String char) {
    return char == ' ' || char == '\n';
  }

  bool _isOpeningComment(String char) {
    return char == '{';
  }

  bool _isNotClosingComment(String char) {
    return char != '}';
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

  Token _number() {
    var firstPart = _getAllNumbers();
    if (_text[_pos] == '.') {
      _pos++;
      var secondPart = _getAllNumbers();
      _pos--;
      return Token(TokenType.realConst, value: firstPart + '.' + secondPart);
    } else {
      _pos--;
      return Token(TokenType.intergerConst, value: firstPart);
    }
  }

  Token _getCompoundSymbol() {
    var token = Token.stringCompoundSymbolToToken[_text[_pos]] ?? Token(TokenType.eof);
    while (Token.stringCompoundSymbolToToken[_text[_pos]] != null) {
      _pos++;
    }

    return token;
  }

  String _skipWhiteSpaceOrNewLine() {
    while (_isWhiteSpace(_text[_pos]) && (_pos < _text.length - 1)) {
      _pos++;
    }

    return _text[_pos];
  }

  String _skipComment() {
    while (_isNotClosingComment(_text[_pos]) && (_pos < _text.length - 1)) {
      _pos++;
    }
    _pos++;

    return _text[_pos];
  }

  String _getAllNumbers() {
    var number = '';

    for(;;) {
      if (_pos < _text.length && _isDigit(_text[_pos])) {
        number += _text[_pos];
        _pos++;
      } else {
        // _pos--;
        break;
      }
    }

    return number;
  }

  Token getCurrentToken() {
    return _currentToken;
  }

  bool check(TokenType type) {
    return _currentToken.type == type;
  }

  Token getNextToken() {
    if (_pos >= _text.length) {
      _currentToken = Token(TokenType.eof);
    } else {
      var currentChar = _text[_pos];

      if (_isWhiteSpaceOrNewLine(currentChar)) {
        currentChar = _skipWhiteSpaceOrNewLine();
      }

      while (_isOpeningComment(currentChar)) {
        currentChar =_skipComment();
        currentChar = _skipWhiteSpaceOrNewLine();
      }

      if (_isAlpha(currentChar)) {
        _currentToken = _id();
      } else if (_isDigit(currentChar)) {
        _currentToken = _number();
      } else if (_isCompoundSymbol(currentChar)) {
        _currentToken = _getCompoundSymbol();
      } else if (Token.stringSymbolToToken[currentChar] != null) {
        _currentToken = Token.stringSymbolToToken[currentChar]!;
      } else if (_pos == _text.length - 1) {
        _currentToken = Token(TokenType.eof);
      } else {
        throw Exception('Error lexing the code at positon: $_pos , char: ${_text[_pos]}');
      }

      _pos++;
    }

    return _currentToken;
  }
}