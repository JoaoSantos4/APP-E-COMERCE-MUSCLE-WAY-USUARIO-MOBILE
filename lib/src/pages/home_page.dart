import 'package:app_muscley/src/controllers/carrinho_controller.dart';
import 'package:app_muscley/src/controllers/sessao_controller.dart';
import 'package:app_muscley/src/database/produto_database.dart';
import 'package:app_muscley/src/models/produto_model.dart';
import 'package:app_muscley/src/theme/app_theme.dart';
import 'package:app_muscley/src/widgets/brand_logo_widget.dart';
import 'package:app_muscley/src/widgets/produto_card_widget.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final buscaController = TextEditingController();

  List<ProdutoModel> produtos = [];
  String categoriaSelecionada = 'TODOS';
  String termoBusca = '';
  bool carregando = true;

  List<String> get categorias {
    final categoriasProdutos =
        produtos.map((produto) => produto.categoria).toSet().toList()..sort();
    return ['TODOS', ...categoriasProdutos];
  }

  List<ProdutoModel> get produtosFiltrados {
    final termo = termoBusca.trim().toLowerCase();

    return produtos.where((produto) {
      final combinaCategoria =
          categoriaSelecionada == 'TODOS' ||
          produto.categoria == categoriaSelecionada;
      final combinaBusca =
          termo.isEmpty ||
          produto.nome.toLowerCase().contains(termo) ||
          produto.descricao.toLowerCase().contains(termo) ||
          produto.categoria.toLowerCase().contains(termo);

      return combinaCategoria && combinaBusca;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    carregarProdutos();
  }

  Future<void> carregarProdutos() async {
    await ProdutoDatabase.inserirProdutosExemplo();
    final listaProdutos = await ProdutoDatabase.listarProdutos();

    if (!mounted) return;

    setState(() {
      produtos = listaProdutos;
      carregando = false;
    });
  }

  void adicionarAoCarrinho(ProdutoModel produto) {
    CarrinhoController.adicionar(produto);
    Navigator.pushNamed(context, '/carrinho').then((_) {
      if (mounted) setState(() {});
    });
  }

  void abrirProduto(ProdutoModel produto) {
    Navigator.pushNamed(context, '/produto', arguments: produto).then((_) {
      if (mounted) setState(() {});
    });
  }

  void abrirCarrinho() {
    Navigator.pushNamed(context, '/carrinho').then((_) {
      if (mounted) setState(() {});
    });
  }

  void sair() {
    SessaoController.sair();
    CarrinhoController.limpar();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  void dispose() {
    buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BrandLogoWidget(iconSize: 38),
        actions: [
          IconButton(
            tooltip: 'Consultor IA',
            onPressed: () => Navigator.pushNamed(context, '/chat-ia'),
            icon: const Icon(Icons.auto_awesome),
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                tooltip: 'Carrinho',
                onPressed: abrirCarrinho,
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
              if (CarrinhoController.quantidadeTotal > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${CarrinhoController.quantidadeTotal}',
                      style: const TextStyle(
                        color: Color(0xFF061017),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: sair,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: carregarProdutos,
              color: AppTheme.primary,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                children: [
                  Text(
                    'Olá, ${SessaoController.primeiroNome}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Escolha suplementos de alta performance para evoluir no treino.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                  _heroCampanha(),
                  const SizedBox(height: 14),
                  _beneficios(),
                  const SizedBox(height: 18),
                  _campoBusca(),
                  const SizedBox(height: 18),
                  _boxIa(),
                  const SizedBox(height: 24),
                  _secaoTitulo(
                    'Departamentos',
                    '${categorias.length - 1} categorias',
                  ),
                  const SizedBox(height: 12),
                  _listaCategorias(),
                  const SizedBox(height: 24),
                  _secaoTitulo(
                    categoriaSelecionada == 'TODOS'
                        ? 'Produtos em destaque'
                        : categoriaSelecionada,
                    '${produtosFiltrados.length} itens',
                  ),
                  const SizedBox(height: 14),
                  if (produtosFiltrados.isEmpty)
                    _semResultados()
                  else
                    ...produtosFiltrados.map(
                      (produto) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: ProdutoCardWidget(
                          produto: produto,
                          onAdicionar: () => adicionarAoCarrinho(produto),
                          onVerDetalhes: () => abrirProduto(produto),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _heroCampanha() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2231), AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'SEMANA DA PERFORMANCE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Monte seu combo ideal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Proteínas, creatina e pré-treinos para cada objetivo.',
                  style: TextStyle(color: Colors.white70, height: 1.35),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    final whey = produtos.firstWhere(
                      (produto) => produto.nome.toLowerCase().contains('whey'),
                      orElse: () => produtos.first,
                    );
                    adicionarAoCarrinho(whey);
                  },
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Comprar destaque'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 86,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(
              Icons.local_drink_outlined,
              color: Colors.white,
              size: 54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _beneficios() {
    const itens = [
      (Icons.local_shipping_outlined, 'Frete grátis acima de R\$ 150'),
      (Icons.payment_outlined, '7% OFF no Pix'),
      (Icons.verified_outlined, 'Compra segura'),
    ];

    return Row(
      children: itens.map((item) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: item == itens.last ? 0 : 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                Icon(item.$1, color: AppTheme.primary, size: 22),
                const SizedBox(height: 8),
                Text(
                  item.$2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _campoBusca() {
    return TextField(
      controller: buscaController,
      onChanged: (valor) {
        setState(() {
          termoBusca = valor;
        });
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Buscar whey, creatina, kit...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: termoBusca.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpar busca',
                onPressed: () {
                  buscaController.clear();
                  setState(() {
                    termoBusca = '';
                  });
                },
                icon: const Icon(Icons.close),
              ),
      ),
    );
  }

  Widget _boxIa() {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/chat-ia'),
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.psychology_outlined, color: AppTheme.primary, size: 34),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consultor Muscleway IA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Receba sugestões de suplementos para seu objetivo.',
                    style: TextStyle(color: AppTheme.textMuted, height: 1.3),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _secaoTitulo(String titulo, String subtitulo) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          subtitulo,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _listaCategorias() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categorias.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return _categoriaChip(categorias[index]);
        },
      ),
    );
  }

  Widget _categoriaChip(String nome) {
    final selecionado = categoriaSelecionada == nome;

    return ChoiceChip(
      label: Text(nome),
      selected: selecionado,
      onSelected: (_) {
        setState(() {
          categoriaSelecionada = nome;
        });
      },
      selectedColor: AppTheme.primary,
      backgroundColor: AppTheme.surface,
      labelStyle: TextStyle(
        color: selecionado ? const Color(0xFF061017) : AppTheme.primary,
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: selecionado ? AppTheme.primary : AppTheme.border,
        ),
      ),
    );
  }

  Widget _semResultados() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off, color: AppTheme.primary, size: 42),
          SizedBox(height: 12),
          Text(
            'Nenhum produto encontrado',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Tente outro termo ou escolha uma categoria diferente.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
