import 'package:pi/src/models/produto_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ProdutoDatabase {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'muscleway_produtos.db');

    _database = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async => _criarTabelaProdutos(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS produtos');
        await _criarTabelaProdutos(db);
      },
    );

    return _database!;
  }

  static Future<void> _criarTabelaProdutos(Database db) async {
    await db.execute('''
      CREATE TABLE produtos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        descricao TEXT NOT NULL,
        preco REAL NOT NULL,
        categoria TEXT NOT NULL,
        imagem TEXT NOT NULL
      )
    ''');
  }

  static Future<void> cadastrarProduto(ProdutoModel produto) async {
    final db = await getDatabase();

    await db.insert('produtos', produto.toMap());
  }

  static Future<void> atualizarProduto(ProdutoModel produto) async {
    final db = await getDatabase();

    await db.update(
      'produtos',
      produto.toMap(),
      where: 'id = ?',
      whereArgs: [produto.id],
    );
  }

  static Future<void> removerProduto(int id) async {
    final db = await getDatabase();

    await db.delete('produtos', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<ProdutoModel>> listarProdutos() async {
    final db = await getDatabase();
    final maps = await db.query('produtos', orderBy: 'categoria, nome');

    return maps.map(ProdutoModel.fromMap).toList();
  }

  static Future<void> inserirProdutosExemplo() async {
    final produtos = await listarProdutos();

    if (produtos.isNotEmpty) {
      return;
    }

    for (final produto in _produtosExemplo) {
      await cadastrarProduto(produto);
    }
  }

  static final List<ProdutoModel> _produtosExemplo = [
    ProdutoModel(
      nome: 'Beta Nos - Limao 200g',
      descricao: 'Pre-treino sabor limao para energia, foco e desempenho nos treinos.',
      preco: 62.90,
      categoria: 'PRE-TREINOS',
      imagem: 'assets/produtos/beta-nos-limao.png',
    ),
    ProdutoModel(
      nome: 'Beta Nos - Uva 200g',
      descricao: 'Pre-treino sabor uva para mais disposicao, foco e intensidade.',
      preco: 62.90,
      categoria: 'PRE-TREINOS',
      imagem: 'assets/produtos/beta-nos-uva.png',
    ),
    ProdutoModel(
      nome: 'Dilaton Pump - 120 capsulas',
      descricao: 'Vasodilatador para auxiliar no pump e no desempenho muscular.',
      preco: 42.90,
      categoria: 'PRE-TREINOS',
      imagem: 'assets/produtos/dilaton.png',
    ),
    ProdutoModel(
      nome: 'Top Whey - Refil 900g',
      descricao: 'Whey protein para recuperacao e ganho de massa muscular.',
      preco: 59.90,
      categoria: 'PROTEINAS',
      imagem: 'assets/produtos/top-whey.png',
    ),
    ProdutoModel(
      nome: '100% Whey - Baunilha 900g',
      descricao: 'Proteina sabor baunilha para completar a ingestao diaria de proteinas.',
      preco: 79.90,
      categoria: 'PROTEINAS',
      imagem: 'assets/produtos/100-baunilha.png',
    ),
    ProdutoModel(
      nome: '100% Whey - Chocolate 900g',
      descricao: 'Proteina sabor chocolate para recuperacao e suporte ao ganho muscular.',
      preco: 79.90,
      categoria: 'PROTEINAS',
      imagem: 'assets/produtos/100-choc.png',
    ),
    ProdutoModel(
      nome: '100% Whey - Morango 900g',
      descricao: 'Proteina sabor morango para auxiliar na recuperacao pos-treino.',
      preco: 79.90,
      categoria: 'PROTEINAS',
      imagem: 'assets/produtos/100-morango.png',
    ),
    ProdutoModel(
      nome: 'Iso Protein Complex - Refil 900g',
      descricao: 'Proteina em po para suporte muscular e recuperacao.',
      preco: 75.90,
      categoria: 'PROTEINAS',
      imagem: 'assets/produtos/iso-protein-complex.png',
    ),
    ProdutoModel(
      nome: 'Iso Whey - Baunilha 900g',
      descricao: 'Whey isolado sabor baunilha para alta ingestao proteica.',
      preco: 121.90,
      categoria: 'PROTEINAS',
      imagem: 'assets/produtos/iso-whey-baunilha.png',
    ),
    ProdutoModel(
      nome: 'Iso Whey - Chocolate 900g',
      descricao: 'Whey isolado sabor chocolate para recuperacao muscular.',
      preco: 121.90,
      categoria: 'PROTEINAS',
      imagem: 'assets/produtos/iso-whey-chocolate.png',
    ),
    ProdutoModel(
      nome: 'Iso Whey - Morango 900g',
      descricao: 'Whey isolado sabor morango para rotina de alta performance.',
      preco: 121.90,
      categoria: 'PROTEINAS',
      imagem: 'assets/produtos/iso-whey-morango.png',
    ),
    ProdutoModel(
      nome: 'Isolate Whey Mix - Pote 907g',
      descricao: 'Whey isolado para alta ingestao proteica e recuperacao.',
      preco: 121.90,
      categoria: 'PROTEINAS',
      imagem: 'assets/produtos/isolate-whey-mix.png',
    ),
    ProdutoModel(
      nome: 'Isolate Whey Mix - Baunilha 907g',
      descricao: 'Whey isolado sabor baunilha para recuperacao e suporte muscular.',
      preco: 121.90,
      categoria: 'PROTEINAS',
      imagem: 'assets/produtos/mix-baunilha.png',
    ),
    ProdutoModel(
      nome: 'Isolate Whey Mix - Chocolate 907g',
      descricao: 'Whey isolado sabor chocolate para ganho e manutencao muscular.',
      preco: 121.90,
      categoria: 'PROTEINAS',
      imagem: 'assets/produtos/mix-chocolate.png',
    ),
    ProdutoModel(
      nome: 'Isolate Whey Mix - Morango 907g',
      descricao: 'Whey isolado sabor morango para completar a dieta proteica.',
      preco: 121.90,
      categoria: 'PROTEINAS',
      imagem: 'assets/produtos/mix-morango.png',
    ),
    ProdutoModel(
      nome: 'Whey 3W Gourmet - Baunilha 907g',
      descricao: 'Whey 3W gourmet sabor baunilha para performance e recuperacao muscular.',
      preco: 139.90,
      categoria: 'PROTEINAS',
      imagem: 'assets/produtos/3w-baunilha.png',
    ),
    ProdutoModel(
      nome: 'Whey 3W Gourmet - Chocolate com Avela 907g',
      descricao: 'Whey 3W gourmet sabor chocolate com avela para recuperacao muscular.',
      preco: 139.90,
      categoria: 'PROTEINAS',
      imagem: 'assets/produtos/3w-choc-avela.png',
    ),
    ProdutoModel(
      nome: 'Whey 3W Gourmet - Morango 907g',
      descricao: 'Whey 3W gourmet sabor morango para suporte ao ganho de massa.',
      preco: 139.90,
      categoria: 'PROTEINAS',
      imagem: 'assets/produtos/3w-morango.png',
    ),
    ProdutoModel(
      nome: 'Creatine Micronized 100% Pure 90g',
      descricao: 'Creatina pura micronizada em embalagem de 90g para forca e desempenho.',
      preco: 49.90,
      categoria: 'AMINOACIDOS',
      imagem: 'assets/produtos/creatine-90g.png',
    ),
    ProdutoModel(
      nome: 'Creatine Micronized 100% Pure 150g',
      descricao: 'Creatina pura micronizada em embalagem de 150g para performance.',
      preco: 69.90,
      categoria: 'AMINOACIDOS',
      imagem: 'assets/produtos/creatine-150g.png',
    ),
    ProdutoModel(
      nome: 'Creatine Micronized 100% Pure 300g',
      descricao: 'Creatina pura micronizada para forca, potencia e performance.',
      preco: 119.90,
      categoria: 'AMINOACIDOS',
      imagem: 'assets/produtos/creatine-300g.png',
    ),
    ProdutoModel(
      nome: 'BCAA Sintex 6:1:1 - 60 capsulas',
      descricao: 'BCAA em capsulas para auxiliar na recuperacao muscular.',
      preco: 29.90,
      categoria: 'AMINOACIDOS',
      imagem: 'assets/produtos/bcaa-60.png',
    ),
    ProdutoModel(
      nome: 'BCAA Sintex 6:1:1 - Limao 150g',
      descricao: 'BCAA em po sabor limao para suporte ao desempenho e recuperacao.',
      preco: 32.90,
      categoria: 'AMINOACIDOS',
      imagem: 'assets/produtos/bcaa-150g-limao.png',
    ),
    ProdutoModel(
      nome: 'BCAA Sintex 6:1:1 - Uva 150g',
      descricao: 'BCAA em po sabor uva para auxiliar na recuperacao muscular.',
      preco: 32.90,
      categoria: 'AMINOACIDOS',
      imagem: 'assets/produtos/bcaa-150g-uva.png',
    ),
    ProdutoModel(
      nome: 'BCAA Sintex 6:1:1 - Limao 300g',
      descricao: 'BCAA em po sabor limao para suporte ao desempenho em treinos intensos.',
      preco: 51.90,
      categoria: 'AMINOACIDOS',
      imagem: 'assets/produtos/bcaa-300g-limao.png',
    ),
    ProdutoModel(
      nome: 'BCAA Sintex 6:1:1 - Uva 300g',
      descricao: 'BCAA em po sabor uva para recuperacao e suporte muscular.',
      preco: 51.90,
      categoria: 'AMINOACIDOS',
      imagem: 'assets/produtos/bcaa-300g-uva.png',
    ),
    ProdutoModel(
      nome: 'Glutamine Powder 150g',
      descricao: 'Glutamina em po para recuperacao e suporte muscular.',
      preco: 39.90,
      categoria: 'AMINOACIDOS',
      imagem: 'assets/produtos/glutamine-150g.png',
    ),
    ProdutoModel(
      nome: 'Glutamine Powder 300g',
      descricao: 'Glutamina em po para recuperacao, suporte muscular e rotina intensa.',
      preco: 66.90,
      categoria: 'AMINOACIDOS',
      imagem: 'assets/produtos/glutamine-300g.png',
    ),
    ProdutoModel(
      nome: 'Thermo Pro Hers 240mg',
      descricao: 'Termogenico voltado para energia, disposicao e emagrecimento.',
      preco: 19.90,
      categoria: 'EMAGRECEDORES',
      imagem: 'assets/produtos/thermo-pro-hers.png',
    ),
    ProdutoModel(
      nome: 'Thermo Pro Hard 400mg',
      descricao: 'Termogenico para auxiliar na queima de gordura e disposicao.',
      preco: 24.90,
      categoria: 'EMAGRECEDORES',
      imagem: 'assets/produtos/thermo-pro-hard.png',
    ),
    ProdutoModel(
      nome: 'L-Carnitine Reload',
      descricao: 'L-carnitina para auxiliar no metabolismo energetico.',
      preco: 29.90,
      categoria: 'EMAGRECEDORES',
      imagem: 'assets/produtos/l-carnitine.png',
    ),
    ProdutoModel(
      nome: 'Testo Hard GH - 60 tabletes',
      descricao: 'Suplemento especifico para suporte hormonal e performance.',
      preco: 30.90,
      categoria: 'ESPECIFICOS',
      imagem: 'assets/produtos/testo-hard-gh.png',
    ),
    ProdutoModel(
      nome: 'ZMA Up - 90 capsulas',
      descricao: 'ZMA com minerais para suporte muscular, descanso e recuperacao.',
      preco: 25.90,
      categoria: 'ESPECIFICOS',
      imagem: 'assets/produtos/zma.png',
    ),
    ProdutoModel(
      nome: 'Hipercalorico Anabolic Gainer Mass - Baunilha 3kg',
      descricao: 'Hipercalorico sabor baunilha para ganho de peso e massa muscular.',
      preco: 72.90,
      categoria: 'ESPECIFICOS',
      imagem: 'assets/produtos/Hipercalorico-Anabolic-Gainer-Mass-baunilha-frente.png',
    ),
    ProdutoModel(
      nome: 'Hipercalorico Anabolic Gainer Mass - Chocolate 3kg',
      descricao: 'Hipercalorico sabor chocolate para auxiliar no ganho de massa.',
      preco: 72.90,
      categoria: 'ESPECIFICOS',
      imagem: 'assets/produtos/Hipercalorico-Anabolic-Gainer-Mass-chocolate-frente.png',
    ),
    ProdutoModel(
      nome: 'Hipercalorico Anabolic Gainer Mass - Morango 3kg',
      descricao: 'Hipercalorico sabor morango para ganho de peso e suporte energetico.',
      preco: 72.90,
      categoria: 'ESPECIFICOS',
      imagem: 'assets/produtos/Hipercalorico-Anabolic-Gainer-Mass-morango-frente.png',
    ),
    ProdutoModel(
      nome: 'Vit-Full - 90 capsulas',
      descricao: 'Multivitaminico para suporte a saude, imunidade e rotina ativa.',
      preco: 25.90,
      categoria: 'VITAMINAS',
      imagem: 'assets/produtos/vit-full.png',
    ),
    ProdutoModel(
      nome: 'Kit Ganho de Massa',
      descricao: 'Kit pronto para auxiliar no ganho de massa muscular.',
      preco: 179.90,
      categoria: 'KIT PRONTO',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'Kit Hipertrofia',
      descricao: 'Kit para suporte a hipertrofia e evolucao muscular.',
      preco: 216.90,
      categoria: 'KIT PRONTO',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'Kit Emagrecedor',
      descricao: 'Kit pronto para auxiliar no processo de emagrecimento.',
      preco: 219.90,
      categoria: 'KIT PRONTO',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'Kit Performance',
      descricao: 'Kit completo para performance, energia e recuperacao.',
      preco: 260.90,
      categoria: 'KIT PRONTO',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'Camiseta Dry Fit Never Lose Your Way',
      descricao: 'Camiseta dry fit confortavel para treino e uso diario.',
      preco: 39.90,
      categoria: 'ACESSORIOS',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'Coqueteleira Muscleway - 600ml',
      descricao: 'Coqueteleira de 600ml para preparo de suplementos.',
      preco: 15.90,
      categoria: 'ACESSORIOS',
      imagem: '',
    ),
  ];
}
