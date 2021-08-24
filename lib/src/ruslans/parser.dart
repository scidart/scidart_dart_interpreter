import 'ast.dart';
import 'lexer.dart';
import 'token.dart';

class Parser {
  Ast ast = Ast(NodeType.empty);
  Lexer lex = Lexer('');

  Parser(Lexer lex) {
    // program : PROGRAM variable SEMI block DOT
    //
    // block : declarations compound_statement
    //
    // declarations : (VAR (variable_declaration SEMI)+)*
    //              | (PROCEDURE ID (LPAREN formal_parameter_list RPAREN)? SEMI block SEMI)*
    //              | empty
    //
    // variable_declaration : ID (COMMA ID)* COLON type_spec
    //
    // formal_parameter_list : formal_parameters
    //                       | formal_parameters SEMI formal_parameter_list
    //
    // formal_parameters : ID (COMMA ID)* COLON type_spec
    //
    // type_spec : INTEGER | REAL
    //
    // compound_statement : BEGIN statement_list END
    //
    // statement_list : statement
    //                | statement SEMI statement_list
    //
    // statement : compound_statement
    //           | assignment_statement
    //           | empty
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
    this.lex = lex;
    lex.getNextToken();
    ast = _program();
  }

  void _throwError(Token token) {
    throw Exception('error parsing ${token.type}');
  }

  void _eat(TokenType tokenType) {
    var currentToken = lex.getCurrentToken();
    if (currentToken.type == tokenType) {
      lex.getNextToken();
    } else {
      _throwError(currentToken);
    }
  }

  /// program : PROGRAM variable SEMI block DOT
  Ast _program() {
    _eat(TokenType.program);
    var varNode = _variable();
    _eat(TokenType.semi);
    var blockNode = _block();
    var programNode = Program(varNode.value, blockNode);
    _eat(TokenType.dot);
    return programNode;
  }

  /// block : declarations compound_statement
  Block _block() {
    var declaration = _declarations();
    var compoundStatement = _compoundStatement();
    var node = Block(declaration, compoundStatement);
    return node;
  }

  /// declarations : (VAR (variable_declaration SEMI)+)*
  ///              | (PROCEDURE ID (LPAREN formal_parameter_list RPAREN)? SEMI block SEMI)*
  ///              | empty
  List<Ast> _declarations() {
    var declarations = <Ast>[];

    while (true) {
      if (lex.check(TokenType.variable)) {
        _eat(TokenType.variable);
        while (lex.check(TokenType.id)) {
          var varDecl = _variableDeclaration();
          declarations.addAll(varDecl);
          _eat(TokenType.semi);
        }
      } else if (lex.check(TokenType.procedure)) {
        _eat(TokenType.procedure);
        var procName = lex.getCurrentToken().getValue();
        _eat(TokenType.id);

        var param;
        if (lex.check(TokenType.lparen)) {
          _eat(TokenType.lparen);
          param = _formalParameterList();
          _eat(TokenType.rparen);
        }
        _eat(TokenType.semi);
        var block = _block();
        var procDecl = ProcedureDecl(procName, param, block);
        declarations.add(procDecl);
        _eat(TokenType.semi);
      } else {
        break;
      }
    }

    return declarations;
  }

  /// formal_parameter_list : formal_parameters
  ///                       | formal_parameters SEMI formal_parameter_list
  List<Param> _formalParameterList() {
    var paramList = <Param>[];

    if (lex.notCheck(TokenType.id)) {
      return paramList;
    }

    paramList.addAll(_formalParamaters());

    while (lex.check(TokenType.semi)) {
      _eat(TokenType.semi);
      paramList.addAll(_formalParamaters());
    }
    return paramList;
  }

  /// formal_parameters : ID (COMMA ID)* COLON type_spec
  List<Param> _formalParamaters() {
    var varNodes = <Var>[];
    varNodes.add(Var(lex.getCurrentToken()));
    _eat(TokenType.id);

    while (lex.check(TokenType.comma)) {
      _eat(TokenType.comma);
      varNodes.add(Var(lex.getCurrentToken()));
      _eat(TokenType.id);
    }

    _eat(TokenType.colon);
    var typeNode = _typeSpec();

    var params = <Param>[];
    for (var varNode in varNodes) {
      params.add(Param(varNode, typeNode));
    }

    return params;
  }

  /// variable_declaration : ID (COMMA ID)* COLON type_spec
  List<Ast> _variableDeclaration() {
    var varNodes = <Var>[];
    varNodes.add(Var(lex.getCurrentToken())); // first ID
    _eat(TokenType.id);

    while (lex.check(TokenType.comma)) {
      _eat(TokenType.comma);
      varNodes.add(Var(lex.getCurrentToken()));
      _eat(TokenType.id);
    }

    _eat(TokenType.colon);

    var typeNode = _typeSpec();
    var varDeclarations = <VarDeclaration>[];
    for (var node in varNodes) {
      varDeclarations.add(VarDeclaration(node, typeNode));
    }

    return varDeclarations;
  }

  /// type_spec : INTEGER
  ///           | REAL
  Type _typeSpec() {
    var node;
    switch (lex.getCurrentToken().type) {
      case TokenType.integer:
        node = Type(lex.getCurrentToken());
        _eat(TokenType.integer);
        break;
      case TokenType.real:
        node = Type(lex.getCurrentToken());
        _eat(TokenType.real);
        break;
      default:
        _throwError(lex.getCurrentToken());
    }

    return node;
  }

  /// compound_statement : BEGIN statement_list END
  Ast _compoundStatement() {
    _eat(TokenType.begin);
    var nodes = _statementList();
    _eat(TokenType.end);

    var root = Compound();
    root.children.addAll(nodes);

    return root;
  }

  /// statement_list : statement
  ///                | statement SEMI statement_list
  List<Ast> _statementList() {
    var node = _statement();
    var results = <Ast>[];
    results.add(node);

    while (lex.check(TokenType.semi)) {
      _eat(TokenType.semi);
      results.add(_statement());
    }

    return results;
  }

  /// statement : compound_statement
  ///           | assignment_statement
  ///           | empty
  Ast _statement() {
    var node;
    switch (lex.getCurrentToken().type) {
      case TokenType.begin:
        node = _compoundStatement();
        break;
      case TokenType.id:
        node = _assignmentStatement();
        break;
      default:
        node = _empty();
        break;
    }

    return node;
  }

  /// assignment_statement : variable ASSIGN expr
  Ast _assignmentStatement() {
    var left = _variable();
    var token = lex.getCurrentToken();
    _eat(TokenType.assign);
    var right = _expr();
    var node = Assign(left, token, right);
    return node;
  }

  /// variable : ID
  Var _variable() {
    var node = Var(lex.getCurrentToken());
    _eat(TokenType.id);
    return node;
  }

  /// empty :
  Ast _empty() {
    return NoOp();
  }

  /// expr: term ((PLUS | MINUS) term)*
  Ast _expr() {
    var node = _term();
    while (lex.getCurrentToken().isPlusMinus()) {
      var currentToken = lex.getCurrentToken();
      switch (lex.getCurrentToken().type) {
        case TokenType.plus:
          _eat(TokenType.plus);
          break;

        case TokenType.minus:
          _eat(TokenType.minus);
          break;

        default:
          _throwError(currentToken);
      }

      node = BinOp(node, currentToken, _term());
    }

    return node;
  }

  /// term : factor ((MUL | INTEGER_DIV | FLOAT_DIV) factor)*
  Ast _term() {
    var node = _factor();

    while (lex.getCurrentToken().isMulDiv())  {
      var currentToken = lex.getCurrentToken();
      switch (lex.getCurrentToken().type) {
        case TokenType.mult:
          _eat(TokenType.mult);
          break;

        case TokenType.intergerDiv:
          _eat(TokenType.intergerDiv);
          break;

        case TokenType.floatDiv:
          _eat(TokenType.floatDiv);
          break;

        default:
          _throwError(currentToken);
      }

      node = BinOp(node, currentToken, _factor());
    }

    return node;
  }

  /// factor : PLUS factor
  ///        | MINUS factor
  ///        | INTEGER_CONST
  ///        | REAL_CONST
  ///        | LPAREN expr RPAREN
  ///        | variable
  Ast _factor() {
    var result = Ast(NodeType.empty);
    var currentToken = lex.getCurrentToken();
    switch (lex.getCurrentToken().type) {
      case TokenType.plus:
        _eat(TokenType.plus);
        result = UnaryOp(currentToken, _factor());
        break;

      case TokenType.minus:
        _eat(TokenType.minus);
        result = UnaryOp(currentToken, _factor());
        break;

      case TokenType.intergerConst:
        _eat(TokenType.intergerConst);
        result = Num(currentToken);
        break;

      case TokenType.realConst:
        _eat(TokenType.realConst);
        result = Num(currentToken);
        break;

      case TokenType.lparen:
        _eat(TokenType.lparen);
        result = _expr();
        _eat(TokenType.rparen);
        break;

      // case TokenType.assign:
      //   result = _expr();
      //   break;

      case TokenType.id:
        result = _variable();
        break;

      default:
        _throwError(currentToken);
    }

    return result;
  }
}