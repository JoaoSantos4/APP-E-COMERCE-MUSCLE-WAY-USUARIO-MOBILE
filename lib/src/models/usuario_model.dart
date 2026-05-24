class UsuarioModel {
  final int? id;
  final String nome;
  final String email;
  final String senhaHash;

  UsuarioModel({
    this.id,
    required this.nome,
    required this.email,
    required this.senhaHash,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome, 'email': email, 'senha_hash': senhaHash};
  }

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      senhaHash: map['senha_hash'],
    );
  }
}
