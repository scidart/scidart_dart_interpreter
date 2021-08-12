import 'ast.dart';
import 'lexer.dart';
import 'token.dart';

class Parser {
  Ast ast = Ast(NodeType.empty);

  Parser(Lexer lex) {
    // program : PROGRAM variable SEMI block DOT
    //
    // block : declarations compound_statement
    //
    // declarations : VAR (variable_declaration SEMI)+
    // | empty
    //
    // variable_declaration : ID (COMMA ID)* COLON type_spec
    //
    // type_spec : INTEGER | REAL
    //
    // compound_statement : BEGIN statement_list END
    //
    // statement_list : statement
    // | statement SEMI statement_list
    //
    // statement : compound_statement
    // | assignment_statement
    // | empty
    //
    // assignment_statement : variable ASSIGN expr
    //
    // empty :
    //
    // expr : term ((PLUS | MINUS) term)*
    //
    // term : factor ((MUL | INTEGER_DIV | FLOAT_DIV) factor)*
    //
    // factor : PLUS factor
    // | MINUS factor
    // | INTEGER_CONST
    // | REAL_CONST
    // | LPAREN expr RPAREN
    // | variable
    //
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

  /// program : PROGRAM variable SEMI block DOT
  Ast _program(Lexer lex) {
    _checkTokenType(lex.getNextToken(), TokenType.program);
    lex.getNextToken();
    var varNode = _variable(lex);
    _checkTokenType(lex.getNextToken(), TokenType.semi);
    var blockNode = _block(lex);
    var programNode = Program(varNode.value, blockNode);
    _checkTokenType(lex.getNextToken(), TokenType.dot);
    return programNode;
  }

  /// block : declarations compound_statement
  Ast _block(Lexer lex) {
    var declaration = _declarations(lex);
    var compoundStatement = _compoundStatement(lex);
    var node = Block(declaration, compoundStatement);
    return node;
  }

  /// declarations : VAR (variable_declaration SEMI)+
  ///              | empty
  List<Ast> _declarations(Lexer lex) {
    var declarations = <Ast>[];
    if (lex.getNextToken().type == TokenType.variable) {
      while (lex.getNextToken().type == TokenType.id) {
        var varDecl = _variableDeclaration(lex);
        declarations.addAll(varDecl);
        _checkTokenType(lex.getNextToken(), TokenType.semi);
      }
    }

    return declarations;
  }

  /// variable_declaration : ID (COMMA ID)* COLON type_spec
  List<Ast> _variableDeclaration(Lexer lex) {
    var varNodes = <Ast>[];
    varNodes.add(Var(lex.getNextToken())); // first ID
    _checkTokenType(lex.getCurrentToken(), TokenType.id);

    while (lex.getNextToken().type == TokenType.comma) {
      varNodes.add(Var(lex.getNextToken()));
      _checkTokenType(lex.getCurrentToken(), TokenType.id);
    }

    _checkTokenType(lex.getCurrentToken(), TokenType.colon);

    var typeNode = _typeSpec(lex);
    var varDeclarations = <Ast>[];
    for (var node in varNodes) {
      varDeclarations.add(VarDeclaration(node, typeNode));
    }

    return varDeclarations;
  }

  /// type_spec : INTEGER
  ///           | REAL
  Ast _typeSpec(Lexer lex) {
    var node;
    switch (lex.getNextToken().type) {
      case TokenType.integer:
        node = Type(lex.getCurrentToken());
        break;
      case TokenType.real:
        node = Type(lex.getCurrentToken());
        break;
      default:
        _throwError(lex.getCurrentToken());
    }

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

  /// variable : ID
  Var _variable(Lexer lex) {
    var node = Var(lex.getCurrentToken());
    _checkTokenType(lex.getCurrentToken(), TokenType.id);
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

  /// term : factor ((MUL | INTEGER_DIV | FLOAT_DIV) factor)*
  Ast _term(Lexer lex) {
    var node = _factor(lex);

    while (lex.getNextToken().isMulDiv())  {
      switch (lex.getCurrentToken().type) {
        case TokenType.mult:
          break;

        case TokenType.intergerDiv:
          break;

        case TokenType.floatDiv:
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
  ///        | INTEGER_CONST
  ///        | REAL_CONST
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

      case TokenType.intergerConst:
        result = Num(lex.getCurrentToken());
        break;

      case TokenType.realConst:
        result = Num(lex.getCurrentToken());
        break;

      case TokenType.lparen:
        result = _expr(lex);
        _checkTokenType(lex.getCurrentToken(), TokenType.rparen);
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
}