class ProdutoModel {
  final int? id;
  final String nome;
  final String descricao;
  final double preco;
  final String categoria;
  final String imagem;

  ProdutoModel({
    this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.categoria,
    required this.imagem,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'categoria': categoria,
      'imagem': imagem,
    };
  }

  factory ProdutoModel.fromMap(Map<String, dynamic> map) {
    return ProdutoModel(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      preco: (map['preco'] as num).toDouble(),
      categoria: map['categoria'],
      imagem: map['imagem'],
    );
  }
}
