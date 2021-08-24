import 'ast.dart';

class AstVisualizer {
  final String _dotScaffold = '''
digraph astgraph {
    node [shape=circle, fontsize=12, fontname="Courier", height=.1];
    ranksep=.3;
    edge [arrowsize=.5]
%s
}
''';
  final List<String> _dotBody = <String>[];
  int nCont = 1;

  AstVisualizer(Ast node) {
    _visit(node);
  }

  void _throwError(Ast node) {
    throw Exception('error generating AST visualization ${node.type}');
  }

  void _insertNewNode(Ast node, String label) {
    node.num = nCont;
    var s = '    node${node.num} [label="$label"]';
    _dotBody.add(s);
    nCont++;
  }

  void _connectNodes(Ast node1, Ast node2) {
    var s = '    node${node1.num} -> node${node2.num}';
    _dotBody.add(s);
  }

  void _visitProgram(Program node) {
    _insertNewNode(node, 'Program');
    _visit(node.block);
    _connectNodes(node, node.block);
  }

  void _visitBlock(Block node) {
    _insertNewNode(node, 'Block');
    for (var decl in node.declarations) {
      _visit(decl);
    }
    _visit(node.compoundStatement);

    for (var declNode in node.declarations) {
      _connectNodes(node, declNode);
    }

    _connectNodes(node, node.compoundStatement);
  }

  void _visitVarDeclaration(VarDeclaration node) {
    _insertNewNode(node, 'VarDecl');
    _visit(node.varNode);
    _connectNodes(node, node.varNode);
    _visit(node.typeNode);
    _connectNodes(node, node.typeNode);
  }

  void _visitType(Type node) {
    _insertNewNode(node, node.token.getTypeName());
  }

  void _visitBinOp(BinOp node) {
    _insertNewNode(node, node.op.getTypeName());
    _visit(node.left);
    _visit(node.right);

    _connectNodes(node, node.left);
    _connectNodes(node, node.right);
  }

  void _visitNum(Num node) {
    _insertNewNode(node, node.token.getValue());
  }

  void _visitUnaryOp(UnaryOp node) {
    _insertNewNode(node, 'unary ${node.op.getValue()}');
    _visit(node.expr);
    _connectNodes(node, node.expr);
  }

  void _visitCompound(Compound node) {
    _insertNewNode(node, 'Compound');
    for (var child in node.children) {
      _visit(child);
      _connectNodes(node, child);
    }
  }

  void _visitAssign(Assign node) {
    _insertNewNode(node, node.op.getTypeName());
    _visit(node.left);
    _visit(node.right);

    _connectNodes(node, node.left);
    _connectNodes(node, node.right);
  }

  void _visitVar(Var node) {
    _insertNewNode(node, node.value);
  }

  void _visitNoOp(NoOp node) {
    _insertNewNode(node, 'NoOP');
  }

  void _visitProcedureDecl(ProcedureDecl node) {
    _insertNewNode(node, 'ProcDecl:${node.name}');
    for (var paramNode in node.params) {
      _visit(paramNode);
      _connectNodes(node, paramNode);
    }
    _visit(node.block);
    _connectNodes(node, node.block);
  }

  void _visitParam(Param node) {
    _insertNewNode(node, 'Param');
    _visit(node.varNode);
    _connectNodes(node, node.varNode);
    _visit(node.typeNode);
    _connectNodes(node, node.typeNode);
  }

  void _visit(Ast node) {
    switch (node.type) {
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

      case NodeType.assign:
        _visitAssign(node as Assign);
        break;

      case NodeType.variable:
        _visitVar(node as Var);
        break;

      case NodeType.noOp:
        _visitNoOp(node as NoOp);
        break;

      case NodeType.type:
        _visitType(node as Type);
        break;

      case NodeType.varDeclaration:
        _visitVarDeclaration(node as VarDeclaration);
        break;

      case NodeType.program:
        _visitProgram(node as Program);
        break;

      case NodeType.block:
        _visitBlock(node as Block);
        break;

      case NodeType.procedure:
        _visitProcedureDecl(node as ProcedureDecl);
        break;

      case NodeType.param:
        _visitParam(node as Param);
        break;

      case NodeType.empty:
        _throwError(node);
        break;
    }
  }

  String genDot() {
    var body = _dotBody.join('\n');
    return _dotScaffold.replaceFirst('%s', body);
  }
}