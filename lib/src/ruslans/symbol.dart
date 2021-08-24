import 'package:scidart_dart_interpreter/src/ruslans/token.dart';

enum SymbolType {
  customType,
  buildinType,
  varType,
  procudure
}

enum ScopeType {
  none,
  global,
  procedure
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

class ProcedureSymbol extends Symbol {
  final List<VarSymbol> _params = <VarSymbol>[];
  ProcedureSymbol(String name) : super(name, SymbolType.procudure);

  void insertParam(VarSymbol param) {
    _params.add(param);
  }
}

class ScopedSymbolTable {
  final _symbols = <String, Symbol>{};
  String scopeName;
  ScopeType scopeType;
  int scopeLevel;
  ScopedSymbolTable? enclosingScope;

  ScopedSymbolTable(this.scopeName, this.scopeType, this.scopeLevel,
      {this.enclosingScope}) {
    _initBuildins();
  }

  void _initBuildins() {
    insert(BuildinTypeSymbol(TokenType.integer.toString()));
    insert(BuildinTypeSymbol(TokenType.real.toString()));
  }

  void insert(Symbol symbol) {
    _symbols[symbol.name] = symbol;
  }

  Symbol? lookup(String name, {bool currentScopeOnly = false}) {
    var symbol = _symbols[name];
    if (symbol != null) {
      return symbol;
    }
    if (currentScopeOnly) {
      return null;
    }
    if (enclosingScope != null) {
      return enclosingScope?.lookup(name);
    } else {
      return null;
    }
  }

  int tableLength() {
    return _symbols.length;
  }

  Map<String, Symbol> getTable() {
    return _symbols;
  }
}