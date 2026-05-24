import 'package:pi/src/models/usuario_model.dart';

class SessaoController {
  static const adminEmail = 'zenzenitsu12@gmail.com';
  static UsuarioModel? usuarioLogado;

  static bool get estaLogado => usuarioLogado != null;

  static bool get isAdmin {
    final email = usuarioLogado?.email.trim().toLowerCase();
    return email == adminEmail || usuarioLogado?.tipoUsuario == 'admin';
  }

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
