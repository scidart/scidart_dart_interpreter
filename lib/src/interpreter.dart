import 'package:scidart_dart_interpreter/src/lexer.dart';
import 'package:scidart_dart_interpreter/src/token.dart';

class Interpreter {

  Interpreter();

  int process(String text) {
    return _expr(text);
  }

  bool _isNotExpectedToken(Token actualToken, TokenType expectedToken) {
    return actualToken.type != expectedToken;
  }

  bool _isFirstPriorityOperand(Token opToken) {
    return _isNotExpectedToken(opToken, TokenType.mult)
        || _isNotExpectedToken(opToken, TokenType.div);
  }

  bool _isSecondPriorityOperand(Token opToken) {
    return _isNotExpectedToken(opToken, TokenType.plus)
        || _isNotExpectedToken(opToken, TokenType.minus);
  }

  // parser / interpreter
  Token _factor(Token opToken) {
    if (_isNotExpectedToken(opToken, TokenType.integer)) {
      throw Exception('Expected plus signal but I got: ${opToken.type}');
    }
    return opToken;
  }

  int _term() {

  }

  int _expr(String text) {
    var lex = Lexer(text);

    var currentToken = lex.getNextToken();
    var term1 = _factor(currentToken);
    var res = term1.getInt();

    currentToken = lex.getNextToken();
    loop: while (_isOperand(currentToken)) {
      switch(currentToken.type) {
        case TokenType.plus:
          var term2 = _factor(lex.getNextToken());
          res += term2.getInt();
          break;
        case TokenType.minus:
          var term2 = _factor(lex.getNextToken());
          res -= term2.getInt();
          break;
        case TokenType.mult:
          var term2 = _factor(lex.getNextToken());
          res *= term2.getInt();
          break;
        case TokenType.div:
          var term2 = _factor(lex.getNextToken());
          res ~/= term2.getInt();
          break;
        case TokenType.integer:
          throw Exception('Unexpected operator token: ${currentToken.type}');
        case TokenType.eof:
          break loop;
      }

      currentToken = lex.getNextToken();
    }

    return res;
  }
}