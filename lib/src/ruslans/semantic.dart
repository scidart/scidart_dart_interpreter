import 'ast.dart';
import 'symbol.dart';

class SemanticAnalyzer {
  ScopedSymbolTable currentScope = ScopedSymbolTable('none', ScopeType.none, -1);

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
    var globalScope = ScopedSymbolTable('global', ScopeType.global, 1);
    currentScope = globalScope;

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

  void _visitProcedureDecl(ProcedureDecl node) {
    var procName = node.name;
    var procSymbol = ProcedureSymbol(procName);
    currentScope.insert(procSymbol);

    var procedureScore = ScopedSymbolTable(procName, ScopeType.procedure, currentScope.scopeLevel + 1, enclosingScope: currentScope);
    currentScope = procedureScore;

    for (var paramNode in node.params) {
      var paramName = paramNode.varNode.value;
      var paramType = currentScope.lookup(paramNode.typeNode.token.getTypeName());
      if (paramType != null) {
        var varSymbol = VarSymbol(paramName, paramType);
        if (currentScope.lookup(paramName) != null) {
          _throwDuplicatedError(node);
        }
        currentScope.insert(varSymbol);
        procSymbol.insertParam(varSymbol);
      } else {
        _throwTypeNotFoundError(node);
      }
    }

    _visit(node.block);
    currentScope = currentScope.enclosingScope!;
  }

  void _visitVarDeclaration(VarDeclaration node) {
    var typeName = node.typeNode;
    var typeSymbol = currentScope.lookup(typeName.token.getTypeName());
    if (typeSymbol != null) {
      var varName = node.varNode.value;
      var varSymbol = VarSymbol(varName, typeSymbol);
      if (currentScope.lookup(varName, currentScopeOnly: true) != null) {
        _throwDuplicatedError(node);
      }
      currentScope.insert(varSymbol);
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
    var typeSymbol = currentScope.lookup(typeName);
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

  void _visitParam(Param node) {
    _visit(node.varNode);
    _visit(node.typeNode);
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

      case NodeType.param:
        _visitParam(node as Param);
        break;

      case NodeType.empty:
        _throwError(node);
    }
  }
}