import 'ast.dart';
import 'lexer.dart';
import 'token.dart';

class Parser {
  Ast ast = Ast(NodeType.empty);

  Parser(Lexer lex) {
    ast = _expr(lex);
  }

  Ast _factor(Lexer lex) {
    var result = Ast(NodeType.empty);
    switch (lex.getNextToken().type) {
      case TokenType.plus:
        result = UnaryOp(lex.getCurrentToken(), _factor(lex));
        break;

      case TokenType.minus:
        result = UnaryOp(lex.getCurrentToken(), _factor(lex));
        break;

      case TokenType.integer:
        result = Num(lex.getCurrentToken());
        break;

      case TokenType.lparen:
        result = _expr(lex);
        break;

      default:
        _throwError(lex.getCurrentToken());
    }

    return result;
  }

  Ast _term(Lexer lex) {
    var node = _factor(lex);

    while (lex.getNextToken().isMulDiv())  {
      switch (lex.getCurrentToken().type) {
        case TokenType.mult:
          break;

        case TokenType.div:
          break;

        default:
          _throwError(lex.getCurrentToken());
      }

      node = BinOp(node, lex.getCurrentToken(), _factor(lex));
    }

    return node;
  }

  void _throwError(Token token) {
    throw Exception('error parsing ${token.type}');
  }

  Ast _expr(Lexer lex) {
    // expr   : term ((PLUS | MINUS) term)*
    // term   : factor ((MUL | DIV) factor)*
    // factor : (PLUS | MINUS) factor | INTEGER | LPAREN expr RPAREN

    var node = _term(lex);
    while (lex.getCurrentToken().isPlusMinus()) {
      switch (lex.getCurrentToken().type) {
        case TokenType.plus:
          break;

        case TokenType.minus:
          break;

        default:
          _throwError(lex.getCurrentToken());
      }

      node = BinOp(node, lex.getCurrentToken(), _term(lex));
    }

    return node;
  }
}