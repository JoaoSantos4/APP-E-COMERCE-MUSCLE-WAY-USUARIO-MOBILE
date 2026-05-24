import 'package:app_muscley/src/models/produto_model.dart';

class CarrinhoItemModel {
  final ProdutoModel produto;
  final int quantidade;

  const CarrinhoItemModel({required this.produto, required this.quantidade});

  double get subtotal => produto.preco * quantidade;

  CarrinhoItemModel copyWith({int? quantidade}) {
    return CarrinhoItemModel(
      produto: produto,
      quantidade: quantidade ?? this.quantidade,
    );
  }
}
