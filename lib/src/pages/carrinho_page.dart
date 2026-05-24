import 'package:pi/src/controllers/carrinho_controller.dart';
import 'package:pi/src/controllers/sessao_controller.dart';
import 'package:pi/src/database/pedido_database.dart';
import 'package:pi/src/models/carrinho_item_model.dart';
import 'package:pi/src/theme/app_theme.dart';
import 'package:pi/src/utils/preco_utils.dart';
import 'package:flutter/material.dart';

class CarrinhoPage extends StatefulWidget {
  const CarrinhoPage({super.key});

  @override
  State<CarrinhoPage> createState() => _CarrinhoPageState();
}

class _CarrinhoPageState extends State<CarrinhoPage> {
  static const double freteGratisAcimaDe = 150;
  final cupomController = TextEditingController();
  String cupomAplicado = '';

  double get valorRestanteFrete {
    final restante = freteGratisAcimaDe - CarrinhoController.valorTotal;
    return restante < 0 ? 0 : restante;
  }

  double get progressoFrete {
    return (CarrinhoController.valorTotal / freteGratisAcimaDe).clamp(0, 1);
  }

  double get desconto {
    return cupomAplicado == 'MUSCLE10' ? CarrinhoController.valorTotal * 0.10 : 0;
  }

  double get totalComDesconto {
    final total = CarrinhoController.valorTotal - desconto;
    return total < 0 ? 0 : total;
  }

  void atualizarQuantidade(VoidCallback acao) {
    setState(acao);
  }

  void aplicarCupom() {
    final cupom = cupomController.text.trim().toUpperCase();

    setState(() {
      cupomAplicado = cupom == 'MUSCLE10' ? cupom : '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cupomAplicado.isEmpty
              ? 'Cupom invalido.'
              : 'Cupom MUSCLE10 aplicado.',
        ),
        backgroundColor: cupomAplicado.isEmpty ? AppTheme.danger : AppTheme.success,
      ),
    );
  }

  Future<void> finalizarPedido() async {
    if (CarrinhoController.itens.isEmpty) return;

    final enderecoController = TextEditingController();
    String pagamento = 'Pix';

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.surface,
              title: const Text('Finalizar compra'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: enderecoController,
                    decoration: const InputDecoration(
                      labelText: 'Endereco de entrega',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: pagamento,
                    decoration: const InputDecoration(
                      labelText: 'Pagamento',
                      prefixIcon: Icon(Icons.payment_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Pix', child: Text('Pix')),
                      DropdownMenuItem(value: 'Cartao', child: Text('Cartao')),
                      DropdownMenuItem(value: 'Dinheiro', child: Text('Dinheiro')),
                    ],
                    onChanged: (valor) {
                      if (valor == null) return;
                      setDialogState(() => pagamento = valor);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmado != true) return;

    final endereco = enderecoController.text.trim();
    if (endereco.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o endereco de entrega.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    final usuario = SessaoController.usuarioLogado;
    final pedidoId = await PedidoDatabase.cadastrarPedido(
      usuarioEmail: usuario?.email ?? 'sem-login',
      usuarioNome: usuario?.nome ?? 'Cliente',
      endereco: endereco,
      pagamento: pagamento,
      cupom: cupomAplicado,
      subtotal: CarrinhoController.valorTotal,
      desconto: desconto,
      total: totalComDesconto,
      itens: CarrinhoController.itens,
    );

    CarrinhoController.limpar();
    setState(() {
      cupomAplicado = '';
      cupomController.clear();
    });

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('Pedido finalizado'),
          content: Text('Pedido #$pedidoId registrado com sucesso.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    cupomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itens = CarrinhoController.itens;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Carrinho',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Historico',
            onPressed: () => Navigator.pushNamed(context, '/historico'),
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          if (itens.isNotEmpty)
            IconButton(
              tooltip: 'Limpar carrinho',
              onPressed: () => atualizarQuantidade(CarrinhoController.limpar),
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: itens.isEmpty
          ? const _CarrinhoVazio()
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _freteCard(),
                const SizedBox(height: 16),
                _cupomCard(),
                const SizedBox(height: 16),
                ...itens.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _itemCarrinho(item),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: itens.isEmpty ? null : _resumoCheckout(),
    );
  }

  Widget _freteCard() {
    final temFreteGratis = valorRestanteFrete == 0;

    return Container(
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
              Icon(
                temFreteGratis
                    ? Icons.verified_outlined
                    : Icons.local_shipping_outlined,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  temFreteGratis
                      ? 'Voce ganhou frete gratis'
                      : 'Faltam ${PrecoUtils.formatar(valorRestanteFrete)} para frete gratis',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progressoFrete,
              minHeight: 8,
              color: AppTheme.primary,
              backgroundColor: AppTheme.surfaceLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cupomCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: cupomController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                hintText: 'Cupom MUSCLE10',
                prefixIcon: Icon(Icons.local_offer_outlined),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: aplicarCupom,
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  Widget _itemCarrinho(CarrinhoItemModel item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: item.produto.imagem.isEmpty
                    ? const Icon(
                        Icons.fitness_center,
                        color: AppTheme.primary,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Image.asset(
                            item.produto.imagem,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.produto.nome,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.produto.categoria,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remover',
                onPressed: () => atualizarQuantidade(
                  () => CarrinhoController.remover(item.produto),
                ),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                PrecoUtils.formatar(item.subtotal),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Diminuir',
                      onPressed: () => atualizarQuantidade(
                        () => CarrinhoController.decrementar(item.produto),
                      ),
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      '${item.quantidade}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Aumentar',
                      onPressed: () => atualizarQuantidade(
                        () => CarrinhoController.incrementar(item.produto),
                      ),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resumoCheckout() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _linhaResumo('Itens', '${CarrinhoController.quantidadeTotal}'),
            const SizedBox(height: 8),
            _linhaResumo(
              'Subtotal',
              PrecoUtils.formatar(CarrinhoController.valorTotal),
            ),
            if (desconto > 0) ...[
              const SizedBox(height: 8),
              _linhaResumo('Desconto', '- ${PrecoUtils.formatar(desconto)}'),
            ],
            const SizedBox(height: 8),
            _linhaResumo(
              'Entrega',
              valorRestanteFrete == 0 ? 'Gratis' : 'A calcular',
            ),
            const Divider(height: 24, color: AppTheme.border),
            _linhaResumo(
              'Total',
              PrecoUtils.formatar(totalComDesconto),
              destaque: true,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: finalizarPedido,
                icon: const Icon(Icons.lock_outline),
                label: const Text('Finalizar compra'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linhaResumo(String label, String valor, {bool destaque = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: destaque ? Colors.white : AppTheme.textMuted,
            fontWeight: destaque ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            color: destaque ? AppTheme.primary : Colors.white,
            fontSize: destaque ? 20 : 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _CarrinhoVazio extends StatelessWidget {
  const _CarrinhoVazio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: AppTheme.primary,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Seu carrinho esta vazio',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Adicione produtos para montar seu combo Muscleway.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Ver produtos'),
            ),
          ],
        ),
      ),
    );
  }
}
