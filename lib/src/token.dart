enum TokenType {
  integer,
  plus,
  minus,
  mult,
  div,
  eof
}

class Token {
  TokenType type;
  String? _value;

  static var stringSymbolToToken = <String, Token>{
    '+': Token(TokenType.plus),
    '-': Token(TokenType.minus),
    '*': Token(TokenType.mult),
    '/': Token(TokenType.div)
  };

  static var tokenToString = <Token, String>{
    Token(TokenType.plus): '+',
    Token(TokenType.minus): '-',
    Token(TokenType.mult): '*',
    Token(TokenType.div): '/'
  };

  Token(this.type, {String? value}) {
    _value = value;
  }

  int getInt() {
    return int.parse(_value!);
  }
}