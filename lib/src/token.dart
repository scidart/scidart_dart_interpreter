enum TokenType {
  // positional tokens
  sof,
  eof,

  // type tokens
  integer,
  real,
  intergerConst,
  realConst,

  // operation tokens
  plus,
  minus,
  mult,
  intergerDiv,
  floatDiv,
  lparen,
  rparen,

  // attribution tokens
  id,
  assign,

  // reserved words tokens
  begin,
  end,
  program,
  variable,

  // statement delimitation tokens
  semi,
  dot,
  colon,
  comma,
}

class Token {
  TokenType type;
  String? _value;

  static var reservedKeywordsStringToToken = <String, Token>{
    'PROGRAM' : Token(TokenType.program),
    'VAR': Token(TokenType.variable),
    'DIV': Token(TokenType.intergerDiv),
    'INTEGER': Token(TokenType.integer),
    'REAL': Token(TokenType.real),
    'BEGIN': Token(TokenType.begin),
    'END': Token(TokenType.end),
  };

  static var stringCompoundSymbolToToken = <String, Token>{
    // attribution tokens
    ':': Token(TokenType.assign),
    '=': Token(TokenType.assign),
  };

  static var stringSymbolToToken = <String, Token>{
    // operation tokens
    '+': Token(TokenType.plus),
    '-': Token(TokenType.minus),
    '*': Token(TokenType.mult),
    '/': Token(TokenType.floatDiv),
    '(': Token(TokenType.lparen),
    ')': Token(TokenType.rparen),

    // statement delimitation tokens
    ';': Token(TokenType.semi),
    '.': Token(TokenType.dot),
    ':': Token(TokenType.colon),
    ',': Token(TokenType.comma),
  };

  static var tokenToString = <Token, String>{
    // operation tokens
    Token(TokenType.plus): '+',
    Token(TokenType.minus): '-',
    Token(TokenType.mult): '*',
    Token(TokenType.floatDiv): '/',
    Token(TokenType.lparen): '(',
    Token(TokenType.rparen): ')',

    // statement delimitation tokens
    Token(TokenType.semi): ';',
    Token(TokenType.dot): '.',
    Token(TokenType.colon): ':',
    Token(TokenType.comma): ',',
  };

  Token(this.type, {String? value}) {
    _value = value;
  }

  int getInt() {
    return int.parse(_value!);
  }

  double getFloat() {
    return double.parse(_value!);
  }

  String getValue() {
    return _value!;
  }

  bool isOperand() {
    return type == TokenType.plus
        || type == TokenType.minus
        || type == TokenType.mult
        || type == TokenType.intergerDiv
        || type == TokenType.floatDiv;
  }

  bool isMulDiv() {
    return type == TokenType.mult
        || type == TokenType.intergerDiv
        || type == TokenType.floatDiv;
  }

  bool isPlusMinus() {
    return type == TokenType.plus
        || type == TokenType.minus;
  }

  bool isNotEof() {
    return type != TokenType.eof;
  }
}