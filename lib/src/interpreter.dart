import 'package:scidart_dart_interpreter/src/lexer.dart';
import 'package:scidart_dart_interpreter/src/token.dart';

import 'ast.dart';
import 'parser.dart';

class Interpreter2 {
  int _factor(Lexer lex) {
    var result;
    switch (lex.getNextToken().type) {
      case TokenType.integer:
        result = lex.getCurrentToken().getInt();
        break;

      case TokenType.lparen:
        result = _expr(lex, 0);
        break;

      default:
        _throwError(lex.getCurrentToken());
    }

    return result;
  }

  int _term(Lexer lex, int result) {
    result = _factor(lex);

    while (lex.getNextToken().isMulDiv())  {
      switch (lex.getCurrentToken().type) {
        case TokenType.mult:
          result *= _factor(lex);
          break;

        case TokenType.div:
          result = result ~/ _factor(lex);
          break;

        default:
          _throwError(lex.getCurrentToken());
      }
    }

    return result;
  }

  void _throwError(Token token) {
    throw Exception('error parsing ${token.type}');
  }

  int _expr(Lexer lex, int result) {
    // expr   : term ((PLUS | MINUS) term)*
    // term   : factor ((MUL | DIV) factor)*
    // factor : INTEGER | LPAREN expr RPAREN

    // expr
    result = _term(lex, result);
    while (lex.getCurrentToken().isPlusMinus()) {
      switch (lex.getCurrentToken().type) {
        case TokenType.plus:
          result += _term(lex, result);
          break;

        case TokenType.minus:
          result -= _term(lex, result);
          break;

        default:
          _throwError(lex.getCurrentToken());
      }
    }

    return result;
  }

  int process(String text) {
    var lex = Lexer(text);
    var result = 0;
    return _expr(lex, result);
  }
}

class Interpreter {
  var globalScope = <String, dynamic>{};

  int process(String text) {
    var lex = Lexer(text);
    var parser = Parser(lex);
    var res = _visit(parser.ast);

    print(globalScope);

    return res;
  }

  int _visitBinOp(BinOp node) {
    switch (node.op.type) {
      case TokenType.plus:
        return _visit(node.left) + _visit(node.right);

      case TokenType.minus:
        return _visit(node.left) - _visit(node.right);

      case TokenType.mult:
        return _visit(node.left) * _visit(node.right);

      case TokenType.div:
        return _visit(node.left) ~/ _visit(node.right);

      default:
        throw Exception('error interpreting ${node.op.type}');
    }
  }

  int _visitNum(Num node) {
    return node.token.getInt();
  }

  int _visitUnaryOp(UnaryOp node) {
    switch (node.op.type) {

      case TokenType.plus:
        return _visit(node.expr);

      case TokenType.minus:
        return -_visit(node.expr);

      default:
        throw Exception('error interpreting ${node.op.type}');
    }
  }

  void _visitCompound(Compound node) {
    for (var child in node.children) {
      _visit(child);
    }
  }

  void _visitAssign(Assign node) {
    var varName = node.left.value;
    globalScope[varName] = _visit(node.right);
  }

  dynamic _visitVar(Var node) {
    var varName = node.value;
    var val = globalScope[varName];
    if (val == null) {
      throw Exception('variable not declared: $varName');
    } else {
      return val;
    }
  }

  void _visitNoOp(NoOp node) {
  }

  int _visit(Ast node) {
    switch (node.type) {

      case NodeType.binOp:
        return _visitBinOp(node as BinOp);

      case NodeType.num:
        return _visitNum(node as Num);

      case NodeType.unaryOp:
        return _visitUnaryOp(node as UnaryOp);

      case NodeType.compound:
        _visitCompound(node as Compound);
        return 0;

      case NodeType.assign:
        _visitAssign(node as Assign);
        return 0;

      case NodeType.variable:
        return _visitVar(node as Var);

      case NodeType.noOp:
        _visitNoOp(node as NoOp);
        return 0;

      default:
        throw Exception('error interpreting ${node.type}');
    }
  }
}