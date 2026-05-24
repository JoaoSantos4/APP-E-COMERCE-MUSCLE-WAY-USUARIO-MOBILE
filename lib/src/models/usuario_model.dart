class UsuarioModel {
  final int? id;
  final String nome;
  final String email;
  final String senhaHash;
  final String tipoUsuario;

  UsuarioModel({
    this.id,
    required this.nome,
    required this.email,
    required this.senhaHash,
    this.tipoUsuario = 'cliente',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha_hash': senhaHash,
      'tipo_usuario': tipoUsuario,
    };
  }

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      senhaHash: map['senha_hash'],
      tipoUsuario: map['tipo_usuario'] ?? 'cliente',
    );
  }
}
