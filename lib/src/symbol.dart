import 'package:scidart_dart_interpreter/src/token.dart';

import 'ast.dart';

enum SymbolType {
  customType,
  buildinType,
  varType
}

class Symbol {
  String name;
  SymbolType type;

  Symbol(this.name, this.type);
}

class BuildinTypeSymbol extends Symbol {
  BuildinTypeSymbol(String name) : super(name, SymbolType.buildinType);
}

class VarSymbol extends Symbol {
  Symbol symbol;
  VarSymbol(String name, this.symbol) : super(name, SymbolType.varType);
}

class SymbolTable {
  final _symbols = <String, Symbol>{};

  SymbolTable() {
    _initBuildins();
  }

  void _initBuildins() {
    define(BuildinTypeSymbol(TokenType.integer.toString()));
    define(BuildinTypeSymbol(TokenType.real.toString()));
  }

  void define(Symbol symbol) {
    _symbols[symbol.name] = symbol;
  }

  Symbol? lookup(String name) {
    return _symbols[name];
  }
}

class SemanticAnalyzer {
  SymbolTable symtab = SymbolTable();

  SemanticAnalyzer(Ast tree) {
    _visit(tree);
  }

  void _throwError(Ast node) {
    throw Exception('Error generating symbol table for: ${node.type}');
  }

  void _throwDuplicatedError(Ast node) {
    throw Exception('Error duplicate identifier found: ${node.type}');
  }

  void _throwTypeNotFoundError(Ast node) {
    throw Exception('Error type not found: ${node.type}');
  }

  void _throwSymbolNotFoundError(Ast node) {
    throw Exception('Error symbol (identifier) not found: ${node.type}');
  }

  void _visitBlock(Block node) {
    for (var decl in node.declarations) {
      _visit(decl);
    }
    _visit(node.compoundStatement);
  }

  void _visitProgram(Program node) {
    _visit(node.block);
  }

  void _visitCompound(Compound node) {
    for (var child in node.children) {
      _visit(child);
    }
  }

  void _visitNoOp(NoOp node) {
  }

  void _visitBinOp(BinOp node) {
    _visit(node.left);
    _visit(node.right);
  }

  void _visitVarDeclaration(VarDeclaration node) {
    var typeName = node.typeNode;
    var typeSymbol = symtab.lookup(typeName.token.type.toString());
    if (typeSymbol != null) {
      var varName = node.varNode.value;
      var varSymbol = VarSymbol(varName, typeSymbol);
      if (symtab.lookup(varName) != null) {
        _throwDuplicatedError(node);
      }
      symtab.define(varSymbol);
    } else {
      _throwTypeNotFoundError(node);
    }
  }

  void _visitAssign(Assign node) {
    _visit(node.right);
    _visit(node.left);
  }

  void _visitVar(Var node) {
    var typeName = node.value;
    var typeSymbol = symtab.lookup(typeName);
    if (typeSymbol == null) {
      _throwSymbolNotFoundError(node);
    }
  }

  void _visitNum(Num node) {
  }

  void _visitUnaryOp(UnaryOp node) {
    _visit(node.expr);
  }

  void _visitType(Type node) {
  }

  void _visitProcedureDecl(ProcedureDecl node) {
  }

  void _visit(Ast node) {
    switch (node.type) {

      case NodeType.block:
        _visitBlock(node as Block);
        break;

      case NodeType.program:
        _visitProgram(node as Program);
        break;

      case NodeType.binOp:
        _visitBinOp(node as BinOp);
        break;

      case NodeType.num:
        _visitNum(node as Num);
        break;

      case NodeType.unaryOp:
        _visitUnaryOp(node as UnaryOp);
        break;

      case NodeType.compound:
        _visitCompound(node as Compound);
        break;

      case NodeType.noOp:
        _visitNoOp(node as NoOp);
        break;

      case NodeType.varDeclaration:
        _visitVarDeclaration(node as VarDeclaration);
        break;

      case NodeType.assign:
        _visitAssign(node as Assign);
        break;

      case NodeType.variable:
        _visitVar(node as Var);
        break;

      case NodeType.type:
        _visitType(node as Type);
        break;

      case NodeType.procedure:
        _visitProcedureDecl(node as ProcedureDecl);
        break;

      default:
        _throwError(node);
    }
  }
}