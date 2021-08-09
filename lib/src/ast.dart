import 'package:scidart_dart_interpreter/src/token.dart';

enum NodeType {
  empty,
  unaryOp,
  binOp,
  num,
  compound,
  assign,
  variable,
  noOp
}

class Ast {
  NodeType type;
  Ast(this.type);
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
  Token op;
  String value = '';
  Var(this.op) : super(NodeType.variable) {
    value = op.getValue();
  }
}

class NoOp extends Ast {
  NoOp() : super(NodeType.noOp);
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