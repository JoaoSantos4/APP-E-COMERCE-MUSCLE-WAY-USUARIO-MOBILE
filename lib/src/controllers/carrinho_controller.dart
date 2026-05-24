import 'package:app_muscley/src/models/carrinho_item_model.dart';
import 'package:app_muscley/src/models/produto_model.dart';

class CarrinhoController {
  static final List<CarrinhoItemModel> _itens = [];

  static List<CarrinhoItemModel> get itens => List.unmodifiable(_itens);

  static int get quantidadeTotal {
    return _itens.fold(0, (total, item) => total + item.quantidade);
  }

  static double get valorTotal {
    return _itens.fold(0, (total, item) => total + item.subtotal);
  }

  static void adicionar(ProdutoModel produto) {
    final index = _itens.indexWhere((item) => item.produto.id == produto.id);

    if (index == -1) {
      _itens.add(CarrinhoItemModel(produto: produto, quantidade: 1));
      return;
    }

    final item = _itens[index];
    _itens[index] = item.copyWith(quantidade: item.quantidade + 1);
  }

  static void incrementar(ProdutoModel produto) {
    adicionar(produto);
  }

  static void decrementar(ProdutoModel produto) {
    final index = _itens.indexWhere((item) => item.produto.id == produto.id);

    if (index == -1) {
      return;
    }

    final item = _itens[index];
    if (item.quantidade <= 1) {
      _itens.removeAt(index);
      return;
    }

    _itens[index] = item.copyWith(quantidade: item.quantidade - 1);
  }

  static void remover(ProdutoModel produto) {
    _itens.removeWhere((item) => item.produto.id == produto.id);
  }

  static void limpar() {
    _itens.clear();
  }
}
