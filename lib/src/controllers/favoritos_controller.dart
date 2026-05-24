import 'package:pi/src/models/produto_model.dart';

class FavoritosController {
  static final List<ProdutoModel> _produtos = [];

  static List<ProdutoModel> get produtos => List.unmodifiable(_produtos);

  static bool contem(ProdutoModel produto) {
    return _produtos.any((item) => item.id == produto.id);
  }

  static void alternar(ProdutoModel produto) {
    if (contem(produto)) {
      _produtos.removeWhere((item) => item.id == produto.id);
      return;
    }

    _produtos.add(produto);
  }

  static void limpar() {
    _produtos.clear();
  }
}
