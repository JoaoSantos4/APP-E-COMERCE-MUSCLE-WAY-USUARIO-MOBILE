import 'package:pi/src/controllers/sessao_controller.dart';
import 'package:pi/src/database/pedido_database.dart';
import 'package:pi/src/theme/app_theme.dart';
import 'package:pi/src/utils/preco_utils.dart';
import 'package:flutter/material.dart';

class HistoricoPedidosPage extends StatelessWidget {
  const HistoricoPedidosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final email = SessaoController.usuarioLogado?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meus pedidos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: PedidoDatabase.listarPedidos(usuarioEmail: email),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pedidos = snapshot.data ?? [];

          if (pedidos.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum pedido encontrado.',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(18),
            children: pedidos
                .asMap()
                .entries
                .map(
                  (entry) => _PedidoCard(
                    pedido: entry.value,
                    numeroUsuario: pedidos.length - entry.key,
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  final Map<String, dynamic> pedido;
  final int numeroUsuario;

  const _PedidoCard({required this.pedido, required this.numeroUsuario});

  @override
  Widget build(BuildContext context) {
    final pedidoId = pedido['id'] as int;
    final data = DateTime.tryParse('${pedido['criado_em']}');
    final dataTexto = data == null
        ? 'Compra registrada'
        : '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            children: [
              Expanded(
                child: Text(
                  'Compra $numeroUsuario',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                PrecoUtils.formatar((pedido['total'] as num).toDouble()),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dataTexto,
            style: const TextStyle(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            'Pagamento: ${pedido['pagamento']}',
            style: const TextStyle(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            'Entrega: ${pedido['endereco']}',
            style: const TextStyle(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: PedidoDatabase.listarItens(pedidoId),
            builder: (context, snapshot) {
              final itens = snapshot.data ?? [];

              return Column(
                children: itens.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        if ((item['produto_imagem'] as String).isNotEmpty)
                          SizedBox(
                            width: 34,
                            height: 34,
                            child: Image.asset(
                              item['produto_imagem'],
                              fit: BoxFit.contain,
                            ),
                          )
                        else
                          const Icon(Icons.fitness_center, color: AppTheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${item['quantidade']}x ${item['produto_nome']}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
