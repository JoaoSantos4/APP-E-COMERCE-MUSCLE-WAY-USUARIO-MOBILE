import 'package:pi/src/controllers/carrinho_controller.dart';
import 'package:pi/src/models/produto_model.dart';
import 'package:pi/src/theme/app_theme.dart';
import 'package:pi/src/utils/preco_utils.dart';
import 'package:flutter/material.dart';

class ProdutoPage extends StatelessWidget {
  const ProdutoPage({super.key});

  void adicionarAoCarrinho(BuildContext context, ProdutoModel produto) {
    CarrinhoController.adicionar(produto);
    Navigator.pushNamed(context, '/carrinho');
  }

  @override
  Widget build(BuildContext context) {
    final produto = ModalRoute.of(context)?.settings.arguments as ProdutoModel?;

    if (produto == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Produto')),
        body: const Center(child: Text('Produto nÃ£o encontrado.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do produto')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _produtoHero(produto),
          const SizedBox(height: 22),
          Text(
            produto.categoria,
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            produto.nome,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            PrecoUtils.formatar(PrecoUtils.valorPix(produto.preco)),
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'no Pix com 7% OFF ou ${PrecoUtils.formatar(produto.preco)} no cartÃ£o',
            style: const TextStyle(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 24),
          _secaoDescricao(produto),
          const SizedBox(height: 18),
          const _BeneficiosProduto(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: () => adicionarAoCarrinho(context, produto),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Adicionar ao carrinho'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _produtoHero(ProdutoModel produto) {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppTheme.surface, Color(0xFF102332)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppTheme.border),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 18,
            top: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppTheme.primary),
              ),
              child: const Text(
                '7% OFF PIX',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const Center(
            child: Icon(
              Icons.local_drink_outlined,
              size: 104,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _secaoDescricao(ProdutoModel produto) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DescriÃ§Ã£o',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            produto.descricao,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 16,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _BeneficiosProduto extends StatelessWidget {
  const _BeneficiosProduto();

  @override
  Widget build(BuildContext context) {
    const beneficios = [
      (Icons.verified_outlined, 'Produto selecionado'),
      (Icons.local_shipping_outlined, 'Entrega rÃ¡pida'),
      (Icons.lock_outline, 'Compra segura'),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: beneficios.map((beneficio) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(beneficio.$1, color: AppTheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                beneficio.$2,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

