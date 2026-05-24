import 'package:pi/src/pages/admin_page.dart';
import 'package:pi/src/pages/cadastro_page.dart';
import 'package:pi/src/pages/carrinho_page.dart';
import 'package:pi/src/pages/chat_ia_page.dart';
import 'package:pi/src/pages/home_page.dart';
import 'package:pi/src/pages/login_page.dart';
import 'package:pi/src/pages/produto_page.dart';
import 'package:pi/src/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppMuscley extends StatelessWidget {
  const AppMuscley({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Muscleway",
      theme: AppTheme.dark,
      routes: {
        '/': (_) => const LoginPage(),
        '/admin': (_) => const AdminPage(),
        '/cadastro': (_) => const CadastroPage(),
        '/home': (_) => const HomePage(),
        '/carrinho': (_) => const CarrinhoPage(),
        '/produto': (_) => const ProdutoPage(),
        '/chat-ia': (_) => const ChatIaPage(),
      },
    );
  }
}
