import 'package:scidart_dart_interpreter/src/lexer.dart';
import 'package:scidart_dart_interpreter/src/token.dart';

import 'ast.dart';
import 'parser.dart';

// class Interpreter2 {
//   int _factor(Lexer lex) {
//     var result;
//     switch (lex.getNextToken().type) {
//       case TokenType.integer:
//         result = lex.getCurrentToken().getInt();
//         break;
//
//       case TokenType.lparen:
//         result = _expr(lex, 0);
//         break;
//
//       default:
//         _throwError(lex.getCurrentToken());
//     }
//
//     return result;
//   }
//
//   int _term(Lexer lex, int result) {
//     result = _factor(lex);
//
//     while (lex.getNextToken().isMulDiv())  {
//       switch (lex.getCurrentToken().type) {
//         case TokenType.mult:
//           result *= _factor(lex);
//           break;
//
//         case TokenType.intergerDiv:
//           result = result ~/ _factor(lex);
//           break;
//
//         default:
//           _throwError(lex.getCurrentToken());
//       }
//     }
//
//     return result;
//   }
//
//   void _throwError(Token token) {
//     throw Exception('error parsing ${token.type}');
//   }
//
//   int _expr(Lexer lex, int result) {
//     // expr   : term ((PLUS | MINUS) term)*
//     // term   : factor ((MUL | DIV) factor)*
//     // factor : INTEGER | LPAREN expr RPAREN
//
//     // expr
//     result = _term(lex, result);
//     while (lex.getCurrentToken().isPlusMinus()) {
//       switch (lex.getCurrentToken().type) {
//         case TokenType.plus:
//           result += _term(lex, result);
//           break;
//
//         case TokenType.minus:
//           result -= _term(lex, result);
//           break;
//
//         default:
//           _throwError(lex.getCurrentToken());
//       }
//     }
//
//     return result;
//   }
//
//   int process(String text) {
//     var lex = Lexer(text);
//     var result = 0;
//     return _expr(lex, result);
//   }
// }

class Interpreter {
  var globalScope = <String, dynamic>{};

  void _throwError(Ast node) {
    throw Exception('error interpreting ${node.type}');
  }

  num process(String text) {
    var lex = Lexer(text);
    var parser = Parser(lex);
    var res = _visit(parser.ast);

    print(globalScope);

    return res;
  }

  num _visitProgram(Program node) {
    return _visit(node.block);
  }

  int _visitBlock(Block node) {
    for (var decl in node.declarations) {
      _visit(decl);
    }
    return 0;
  }

  int _visitVarDeclaration(VarDeclaration node) {
    return 0;
  }

  int _visitType(Type node) {
    return 0;
  }

  num _visitBinOp(BinOp node) {
    var result;
    switch (node.op.type) {
      case TokenType.plus:
        result = _visit(node.left) + _visit(node.right);
        break;

      case TokenType.minus:
        result = _visit(node.left) - _visit(node.right);
        break;

      case TokenType.mult:
        result = _visit(node.left) * _visit(node.right);
        break;

      case TokenType.intergerDiv:
        result = _visit(node.left) ~/ _visit(node.right);
        break;

      case TokenType.floatDiv:
        result = _visit(node.left) / _visit(node.right);
        break;

      default:
        _throwError(node);
    }

    return result;
  }

  int _visitNum(Num node) {
    return node.token.getInt();
  }

  int _visitUnaryOp(UnaryOp node) {
    var result;
    switch (node.op.type) {

      case TokenType.plus:
        result = _visit(node.expr);
        break;

      case TokenType.minus:
        result = -_visit(node.expr);
        break;

      default:
        _throwError(node);
    }

    return result;
  }

  void _visitCompound(Compound node) {
    for (var child in node.children) {
      _visit(child);
    }
  }

  void _visitAssign(Assign node) {
    var varName = node.left.token.getValue();
    globalScope[varName] = _visit(node.right);
  }

  dynamic _visitVar(Var node) {
    var varName = node.token.getValue();
    var val = globalScope[varName];
    if (val == null) {
      throw Exception('variable not declared: $varName');
    } else {
      return val;
    }
  }

  void _visitNoOp(NoOp node) {
  }

  num _visit(Ast node) {
    var result;
    switch (node.type) {

      case NodeType.binOp:
        result = _visitBinOp(node as BinOp);
        break;

      case NodeType.num:
        result = _visitNum(node as Num);
        break;

      case NodeType.unaryOp:
        result = _visitUnaryOp(node as UnaryOp);
        break;

      case NodeType.compound:
        _visitCompound(node as Compound);
        result = 0;
        break;

      case NodeType.assign:
        _visitAssign(node as Assign);
        result = 0;
        break;

      case NodeType.variable:
        result = _visitVar(node as Var);
        break;

      case NodeType.noOp:
        _visitNoOp(node as NoOp);
        result = 0;
        break;

      case NodeType.type:
        result = _visitType(node as Type);
        break;

      case NodeType.varDeclaration:
        result = _visitVarDeclaration(node as VarDeclaration);
        break;

      case NodeType.program:
        result = _visitProgram(node as Program);
        break;

      case NodeType.block:
        result = _visitBlock(node as Block);
        break;

      default:
        _throwError(node);
    }

    return result;
  }
}