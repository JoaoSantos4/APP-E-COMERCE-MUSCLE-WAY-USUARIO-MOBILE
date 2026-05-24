import 'package:pi/src/models/produto_model.dart';
import 'package:pi/src/theme/app_theme.dart';
import 'package:pi/src/utils/preco_utils.dart';
import 'package:flutter/material.dart';

class ProdutoCardWidget extends StatelessWidget {
  final ProdutoModel produto;
  final VoidCallback onAdicionar;
  final VoidCallback onVerDetalhes;
  final VoidCallback? onFavorito;
  final bool favorito;

  const ProdutoCardWidget({
    required this.produto,
    required this.onAdicionar,
    required this.onVerDetalhes,
    this.onFavorito,
    this.favorito = false,
    super.key,
  });

  IconData get iconeCategoria {
    final categoria = produto.categoria.toLowerCase();

    if (categoria.contains('prote')) return Icons.local_drink_outlined;
    if (categoria.contains('amino')) return Icons.science_outlined;
    if (categoria.contains('treino')) return Icons.flash_on_outlined;
    if (categoria.contains('kit')) return Icons.inventory_2_outlined;
    if (categoria.contains('acess')) return Icons.shopping_bag_outlined;
    if (categoria.contains('vit')) return Icons.health_and_safety_outlined;
    if (categoria.contains('emagre')) return Icons.local_fire_department;
    return Icons.fitness_center;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onVerDetalhes,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.28),
                    ),
                  ),
                  child: produto.imagem.isEmpty
                      ? Icon(
                          iconeCategoria,
                          color: AppTheme.primary,
                          size: 34,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Image.asset(
                              produto.imagem,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Etiqueta(texto: produto.categoria),
                      const SizedBox(height: 8),
                      Text(
                        produto.nome,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          height: 1.18,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onFavorito != null)
                  IconButton(
                    tooltip: favorito ? 'Remover dos favoritos' : 'Favoritar',
                    onPressed: onFavorito,
                    icon: Icon(
                      favorito ? Icons.favorite : Icons.favorite_border,
                      color: favorito ? AppTheme.danger : Colors.white70,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              produto.descricao,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, height: 1.35),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        PrecoUtils.formatar(PrecoUtils.valorPix(produto.preco)),
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'no Pix ou ${PrecoUtils.formatar(produto.preco)} no cartao',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  tooltip: 'Adicionar ao carrinho',
                  onPressed: onAdicionar,
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: const Color(0xFF061017),
                  ),
                  icon: const Icon(Icons.add_shopping_cart),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: onVerDetalhes,
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('Ver detalhes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;

  const _Etiqueta({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.35)),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: AppTheme.primary,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
