import 'package:scidart_dart_interpreter/src/token.dart';

enum NodeType{
  empty,
  unaryop,
  binop,
  num
}

class Ast {
  NodeType type;
  Ast(this.type);
}

class BinOp extends Ast {
  Ast left;
  Token op;
  Ast right;

  BinOp(this.left, this.op, this.right) : super(NodeType.binop);
}

class Num extends Ast {
  Token token;

  Num(this.token) : super(NodeType.num);
}

class UnaryOp extends Ast {
  Token op;
  Ast expr;

  UnaryOp(this.op, this.expr) : super(NodeType.unaryop);
}