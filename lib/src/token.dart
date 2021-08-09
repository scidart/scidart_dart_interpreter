enum TokenType {
  sof,
  integer,
  plus,
  minus,
  mult,
  div,
  eof,
  lparen,
  rparen,
  semi,
  dot,

  assign,

  id,
  begin,
  end,
}

class Token {
  TokenType type;
  String? _value;

  static var reservedKeywordsStringToToken = <String, Token>{
    'BEGIN': Token(TokenType.begin),
    'END': Token(TokenType.end),
  };

  static var stringCompoundSymbolToToken = <String, Token>{
    ':': Token(TokenType.assign),
    '=': Token(TokenType.assign),
  };

  static var stringSymbolToToken = <String, Token>{
    '+': Token(TokenType.plus),
    '-': Token(TokenType.minus),
    '*': Token(TokenType.mult),
    '/': Token(TokenType.div),
    '(': Token(TokenType.lparen),
    ')': Token(TokenType.rparen),
    ';': Token(TokenType.semi),
    '.': Token(TokenType.dot),
  };

  static var tokenToString = <Token, String>{
    Token(TokenType.plus): '+',
    Token(TokenType.minus): '-',
    Token(TokenType.mult): '*',
    Token(TokenType.div): '/',
    Token(TokenType.lparen): '(',
    Token(TokenType.rparen): ')',
    Token(TokenType.semi): ';',
    Token(TokenType.dot): '.',
  };

  Token(this.type, {String? value}) {
    _value = value;
  }

  int getInt() {
    return int.parse(_value!);
  }

  String getValue() {
    return _value!;
  }

  bool isOperand() {
    return type == TokenType.plus
        || type == TokenType.minus
        || type == TokenType.mult
        || type == TokenType.div;
  }

  bool isMulDiv() {
    return type == TokenType.mult
        || type == TokenType.div;
  }

  bool isPlusMinus() {
    return type == TokenType.plus
        || type == TokenType.minus;
  }

  bool isNotEof() {
    return type != TokenType.eof;
  }
}