import 'package:pi/src/controllers/carrinho_controller.dart';
import 'package:pi/src/controllers/favoritos_controller.dart';
import 'package:pi/src/models/produto_model.dart';
import 'package:pi/src/theme/app_theme.dart';
import 'package:pi/src/widgets/produto_card_widget.dart';
import 'package:flutter/material.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  void abrirProduto(ProdutoModel produto) {
    Navigator.pushNamed(context, '/produto', arguments: produto).then((_) {
      if (mounted) setState(() {});
    });
  }

  void adicionarAoCarrinho(ProdutoModel produto) {
    CarrinhoController.adicionar(produto);
    Navigator.pushNamed(context, '/carrinho').then((_) {
      if (mounted) setState(() {});
    });
  }

  void alternarFavorito(ProdutoModel produto) {
    setState(() {
      FavoritosController.alternar(produto);
    });
  }

  @override
  Widget build(BuildContext context) {
    final produtos = FavoritosController.produtos;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favoritos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      body: produtos.isEmpty
          ? const Center(
              child: Text(
                'Nenhum favorito ainda.',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(18),
              children: produtos.map((produto) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: ProdutoCardWidget(
                    produto: produto,
                    favorito: true,
                    onFavorito: () => alternarFavorito(produto),
                    onAdicionar: () => adicionarAoCarrinho(produto),
                    onVerDetalhes: () => abrirProduto(produto),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
