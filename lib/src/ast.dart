import 'package:scidart_dart_interpreter/src/token.dart';

enum NodeType {
  // content
  empty,

  // operations
  unaryOp,
  binOp,

  // type nodes
  num,
  variable,

  // attribution nodes
  assign,
  type,
  varDeclaration,

  // statement nodes
  compound,
  noOp,
  program,
  block,
}

class Ast {
  NodeType type;
  Ast(this.type);
}

class BinOp extends Ast {
  Ast left;
  Token op;
  Ast right;

  BinOp(this.left, this.op, this.right) : super(NodeType.binOp);
}

class Num extends Ast {
  Token token;

  Num(this.token) : super(NodeType.num);
}

class UnaryOp extends Ast {
  Token op;
  Ast expr;

  UnaryOp(this.op, this.expr) : super(NodeType.unaryOp);
}

class Compound extends Ast {
  List<Ast> children = [];

  Compound() : super(NodeType.compound);
}

class Assign extends Ast {
  Var left;
  Token op;
  Ast right;
  Assign(this.left, this.op, this.right) : super(NodeType.assign);
}

class Var extends Ast  {
  Token token;
  String value = '';
  Var(this.token) : super(NodeType.variable) {
    value = token.getValue();
  }
}

class NoOp extends Ast {
  NoOp() : super(NodeType.noOp);
}

class Program extends Ast {
  String name;
  Ast block;
  Program(this.name, this.block) : super(NodeType.program);
}

class Block extends Ast {
  List<Ast> declarations;
  Ast compoundStatement;
  Block(this.declarations, this.compoundStatement) : super(NodeType.block);
}

class VarDeclaration extends Ast {
  Ast varNode;
  Ast typeNode;
  VarDeclaration(this.varNode, this.typeNode) : super(NodeType.varDeclaration);
}

class Type extends Ast {
  Token token;
  Type(this.token) : super(NodeType.type);
}