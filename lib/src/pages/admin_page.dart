import 'package:pi/src/controllers/sessao_controller.dart';
import 'package:pi/src/database/pedido_database.dart';
import 'package:pi/src/database/produto_database.dart';
import 'package:pi/src/database/usuario_database.dart';
import 'package:pi/src/models/produto_model.dart';
import 'package:pi/src/models/usuario_model.dart';
import 'package:pi/src/theme/app_theme.dart';
import 'package:pi/src/utils/preco_utils.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    if (!SessaoController.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acesso restrito')),
        body: Center(
          child: FilledButton.icon(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            icon: const Icon(Icons.lock_outline),
            label: const Text('Voltar para login'),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Painel admin',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          actions: [
            IconButton(
              tooltip: 'Loja',
              onPressed: () => Navigator.pushNamed(context, '/home'),
              icon: const Icon(Icons.storefront_outlined),
            ),
            IconButton(
              tooltip: 'Sair',
              onPressed: () {
                SessaoController.sair();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              icon: const Icon(Icons.logout),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people_outline), text: 'Usuarios'),
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Produtos'),
              Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Pedidos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _UsuariosAdminTab(),
            _ProdutosAdminTab(),
            _PedidosAdminTab(),
          ],
        ),
      ),
    );
  }
}

class _UsuariosAdminTab extends StatefulWidget {
  const _UsuariosAdminTab();

  @override
  State<_UsuariosAdminTab> createState() => _UsuariosAdminTabState();
}

class _UsuariosAdminTabState extends State<_UsuariosAdminTab> {
  late Future<List<UsuarioModel>> usuariosFuture;
  String busca = '';

  @override
  void initState() {
    super.initState();
    recarregar();
  }

  void recarregar() {
    usuariosFuture = UsuarioDatabase.listarUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UsuarioModel>>(
      future: usuariosFuture,
      builder: (context, snapshot) {
        final usuarios = (snapshot.data ?? []).where((usuario) {
          final termo = busca.trim().toLowerCase();
          return termo.isEmpty ||
              usuario.nome.toLowerCase().contains(termo) ||
              usuario.email.toLowerCase().contains(termo);
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            TextField(
              onChanged: (valor) => setState(() => busca = valor),
              decoration: const InputDecoration(
                hintText: 'Buscar usuario',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 14),
            _ResumoCard(
              titulo: 'Usuarios cadastrados',
              valor: '${usuarios.length}',
              icone: Icons.people_outline,
            ),
            const SizedBox(height: 14),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator())
            else if (usuarios.isEmpty)
              const _Vazio(texto: 'Nenhum usuario encontrado.')
            else
              ...usuarios.map(
                (usuario) => _UsuarioCard(
                  usuario: usuario,
                  onExcluir: usuario.email == SessaoController.adminEmail
                      ? null
                      : () async {
                          await UsuarioDatabase.excluirUsuario(usuario.id!);
                          setState(recarregar);
                        },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProdutosAdminTab extends StatefulWidget {
  const _ProdutosAdminTab();

  @override
  State<_ProdutosAdminTab> createState() => _ProdutosAdminTabState();
}

class _ProdutosAdminTabState extends State<_ProdutosAdminTab> {
  late Future<List<ProdutoModel>> produtosFuture;
  String busca = '';

  @override
  void initState() {
    super.initState();
    recarregar();
  }

  void recarregar() {
    produtosFuture = ProdutoDatabase.listarProdutos();
  }

  Future<void> abrirFormulario([ProdutoModel? produto]) async {
    final nomeController = TextEditingController(text: produto?.nome ?? '');
    final descricaoController =
        TextEditingController(text: produto?.descricao ?? '');
    final precoController =
        TextEditingController(text: produto == null ? '' : '${produto.preco}');
    final categoriaController =
        TextEditingController(text: produto?.categoria ?? '');
    final imagemController = TextEditingController(text: produto?.imagem ?? '');

    final salvou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(produto == null ? 'Novo produto' : 'Editar produto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome')),
                const SizedBox(height: 10),
                TextField(controller: descricaoController, decoration: const InputDecoration(labelText: 'Descricao')),
                const SizedBox(height: 10),
                TextField(controller: precoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Preco')),
                const SizedBox(height: 10),
                TextField(controller: categoriaController, decoration: const InputDecoration(labelText: 'Categoria')),
                const SizedBox(height: 10),
                TextField(controller: imagemController, decoration: const InputDecoration(labelText: 'Imagem')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salvar')),
          ],
        );
      },
    );

    if (salvou != true) return;

    final novoProduto = ProdutoModel(
      id: produto?.id,
      nome: nomeController.text.trim(),
      descricao: descricaoController.text.trim(),
      preco: double.tryParse(precoController.text.replaceAll(',', '.')) ?? 0,
      categoria: categoriaController.text.trim().toUpperCase(),
      imagem: imagemController.text.trim(),
    );

    if (produto == null) {
      await ProdutoDatabase.cadastrarProduto(novoProduto);
    } else {
      await ProdutoDatabase.atualizarProduto(novoProduto);
    }

    setState(recarregar);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProdutoModel>>(
      future: produtosFuture,
      builder: (context, snapshot) {
        final produtos = (snapshot.data ?? []).where((produto) {
          final termo = busca.trim().toLowerCase();
          return termo.isEmpty ||
              produto.nome.toLowerCase().contains(termo) ||
              produto.categoria.toLowerCase().contains(termo);
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (valor) => setState(() => busca = valor),
                    decoration: const InputDecoration(
                      hintText: 'Buscar produto',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  tooltip: 'Novo produto',
                  onPressed: () => abrirFormulario(),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ResumoCard(
              titulo: 'Produtos cadastrados',
              valor: '${produtos.length}',
              icone: Icons.inventory_2_outlined,
            ),
            const SizedBox(height: 14),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator())
            else if (produtos.isEmpty)
              const _Vazio(texto: 'Nenhum produto encontrado.')
            else
              ...produtos.map(
                (produto) => _ProdutoAdminCard(
                  produto: produto,
                  onEditar: () => abrirFormulario(produto),
                  onExcluir: () async {
                    await ProdutoDatabase.removerProduto(produto.id!);
                    setState(recarregar);
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PedidosAdminTab extends StatelessWidget {
  const _PedidosAdminTab();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: PedidoDatabase.listarPedidos(),
      builder: (context, snapshot) {
        final pedidos = snapshot.data ?? [];

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _ResumoCard(
              titulo: 'Pedidos registrados',
              valor: '${pedidos.length}',
              icone: Icons.receipt_long_outlined,
            ),
            const SizedBox(height: 14),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator())
            else if (pedidos.isEmpty)
              const _Vazio(texto: 'Nenhum pedido encontrado.')
            else
              ...pedidos.map((pedido) => _PedidoAdminCard(pedido: pedido)),
          ],
        );
      },
    );
  }
}

class _ResumoCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;

  const _ResumoCard({
    required this.titulo,
    required this.valor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(icone, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ),
          Text(
            valor,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _UsuarioCard extends StatelessWidget {
  final UsuarioModel usuario;
  final VoidCallback? onExcluir;

  const _UsuarioCard({required this.usuario, required this.onExcluir});

  @override
  Widget build(BuildContext context) {
    return _PainelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, color: AppTheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  usuario.nome,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                ),
              ),
              if (onExcluir != null)
                IconButton(
                  tooltip: 'Excluir usuario',
                  onPressed: onExcluir,
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          Text(usuario.email, style: const TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 6),
          Text('Tipo: ${usuario.tipoUsuario}', style: const TextStyle(color: AppTheme.primary)),
          const SizedBox(height: 6),
          SelectableText(
            usuario.senhaHash,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ProdutoAdminCard extends StatelessWidget {
  final ProdutoModel produto;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _ProdutoAdminCard({
    required this.produto,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return _PainelCard(
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: produto.imagem.isEmpty
                ? const Icon(Icons.fitness_center, color: AppTheme.primary)
                : Image.asset(produto.imagem, fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto.nome,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(produto.categoria, style: const TextStyle(color: AppTheme.textMuted)),
                const SizedBox(height: 4),
                Text(
                  PrecoUtils.formatar(produto.preco),
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          IconButton(onPressed: onEditar, icon: const Icon(Icons.edit_outlined)),
          IconButton(onPressed: onExcluir, icon: const Icon(Icons.delete_outline)),
        ],
      ),
    );
  }
}

class _PedidoAdminCard extends StatelessWidget {
  final Map<String, dynamic> pedido;

  const _PedidoAdminCard({required this.pedido});

  @override
  Widget build(BuildContext context) {
    return _PainelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pedido #${pedido['id']}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                PrecoUtils.formatar((pedido['total'] as num).toDouble()),
                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('${pedido['usuario_nome']} - ${pedido['usuario_email']}', style: const TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 4),
          Text('Pagamento: ${pedido['pagamento']}', style: const TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 4),
          Text('Entrega: ${pedido['endereco']}', style: const TextStyle(color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}

class _PainelCard extends StatelessWidget {
  final Widget child;

  const _PainelCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: child,
    );
  }
}

class _Vazio extends StatelessWidget {
  final String texto;

  const _Vazio({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Text(texto, style: const TextStyle(color: AppTheme.textMuted)),
      ),
    );
  }
}
