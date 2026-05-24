import 'package:app_muscley/src/models/usuario_model.dart';

class SessaoController {
  static UsuarioModel? usuarioLogado;

  static String get primeiroNome {
    final nome = usuarioLogado?.nome.trim();

    if (nome == null || nome.isEmpty) {
      return 'atleta';
    }

    return nome.split(' ').first;
  }

  static void entrar(UsuarioModel usuario) {
    usuarioLogado = usuario;
  }

  static void sair() {
    usuarioLogado = null;
  }
}
