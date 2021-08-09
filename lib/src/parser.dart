import 'ast.dart';
import 'lexer.dart';
import 'token.dart';

class Parser {
  Ast ast = Ast(NodeType.empty);

  Parser(Lexer lex) {
    // program : compound_statement DOT
    // compound_statement : BEGIN statement_list END
    // statement_list : statement
    //                | statement SEMI statement_list
    // statement : compound_statement
    //           | assignment_statement
    //           | empty
    // assignment_statement : variable ASSIGN expr
    // empty :
    // expr: term ((PLUS | MINUS) term)*
    // term: factor ((MUL | DIV) factor)*
    // factor : PLUS factor
    //        | MINUS factor
    //        | INTEGER
    //        | LPAREN expr RPAREN
    //        | variable
    // variable: ID

    ast = _program(lex);
  }

  void _throwError(Token token) {
    throw Exception('error parsing ${token.type}');
  }

  void _checkTokenType(Token token, TokenType tokenType, {bool throwErrorEqual = false}) {
    if (throwErrorEqual) {
      if (token.type == tokenType) {
        _throwError(token);
      }
    } else {
      if (token.type != tokenType) {
        _throwError(token);
      }
    }
  }

  /// program : compound_statement DOT
  Ast _program(Lexer lex) {
    lex.getNextToken();
    var node = _compoundStatement(lex);
    _checkTokenType(lex.getNextToken(), TokenType.dot);
    return node;
  }

  /// compound_statement : BEGIN statement_list END
  Ast _compoundStatement(Lexer lex) {
    _checkTokenType(lex.getCurrentToken(), TokenType.begin);
    var nodes = _statementList(lex);
    _checkTokenType(lex.getCurrentToken(), TokenType.end);

    var root = Compound();
    root.children.addAll(nodes);

    return root;
  }

  /// statement_list : statement
  ///                | statement SEMI statement_list
  List<Ast> _statementList(Lexer lex) {
    var node = _statement(lex);
    var results = <Ast>[];
    results.add(node);

    while (lex.getCurrentToken().type == TokenType.semi) {
      results.add(_statement(lex));
    }

    _checkTokenType(lex.getCurrentToken(), TokenType.id, throwErrorEqual: true);

    return results;
  }

  /// statement : compound_statement
  ///           | assignment_statement
  ///           | empty
  Ast _statement(Lexer lex) {
    var node;
    switch (lex.getNextToken().type) {
      case TokenType.begin:
        node = _compoundStatement(lex);
        lex.getNextToken();
        break;
      case TokenType.id:
        node = _assignmentStatement(lex);
        break;
      default:
        node = _empty();
        break;
    }

    return node;
  }

  /// assignment_statement : variable ASSIGN expr
  Ast _assignmentStatement(Lexer lex) {
    var left = _variable(lex);
    var token = lex.getNextToken();
    _checkTokenType(token, TokenType.assign);
    var right = _expr(lex);
    var node = Assign(left, token, right);
    return node;
  }

  /// empty :
  Ast _empty() {
    return NoOp();
  }

  /// expr: term ((PLUS | MINUS) term)*
  Ast _expr(Lexer lex) {
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

  /// term: factor ((MUL | DIV) factor)*
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

  /// factor : PLUS factor
  ///        | MINUS factor
  ///        | INTEGER
  ///        | LPAREN expr RPAREN
  ///        | variable
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

      case TokenType.assign:
        result = _expr(lex);
        break;

      case TokenType.id:
        result = _variable(lex);
        break;

      default:
        _throwError(lex.getCurrentToken());
    }

    return result;
  }

  /// variable : ID
  Var _variable(Lexer lex) {
    var node = Var(lex.getCurrentToken());
    _checkTokenType(lex.getCurrentToken(), TokenType.id);
    return node;
  }
}