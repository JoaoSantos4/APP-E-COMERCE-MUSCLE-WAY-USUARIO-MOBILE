import 'package:app_muscley/src/models/produto_model.dart';
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
      version: 1,
      onCreate: (db, version) async {
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
      },
    );

    return _database!;
  }

  static Future<void> cadastrarProduto(ProdutoModel produto) async {
    final db = await getDatabase();

    await db.insert('produtos', produto.toMap());
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
      nome: 'Beta Nos - 200g',
      descricao: 'Pré-treino para energia, foco e desempenho.',
      preco: 62.90,
      categoria: 'PRÉ-TREINOS',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'Top Whey - Refil 900g',
      descricao: 'Whey protein para recuperação e ganho de massa muscular.',
      preco: 59.90,
      categoria: 'PROTEÍNAS',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'Iso Protein Complex - Refil 900g',
      descricao: 'Proteína em pó para suporte muscular e recuperação.',
      preco: 75.90,
      categoria: 'PROTEÍNAS',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'Isolate Whey Mix - Pote 907g',
      descricao: 'Whey isolado para alta ingestão proteica e recuperação.',
      preco: 121.90,
      categoria: 'PROTEÍNAS',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'Whey 3W Gourmet - Pote 907g',
      descricao: 'Whey 3W gourmet para performance e recuperação muscular.',
      preco: 139.90,
      categoria: 'PROTEÍNAS',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'Creatine Micronized 100% Pure 300g',
      descricao: 'Creatina pura micronizada para força e performance.',
      preco: 119.90,
      categoria: 'AMINOÁCIDOS',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'BCAA Sintex 6:1:1 150g',
      descricao: 'Aminoácido BCAA para auxiliar na recuperação muscular.',
      preco: 32.90,
      categoria: 'AMINOÁCIDOS',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'BCAA Sintex 6:1:1 300g',
      descricao: 'BCAA em pó para suporte ao desempenho e recuperação.',
      preco: 51.90,
      categoria: 'AMINOÁCIDOS',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'Glutamine Powder 300g',
      descricao: 'Glutamina em pó para recuperação e suporte muscular.',
      preco: 66.90,
      categoria: 'AMINOÁCIDOS',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'Thermo Pro Hers 240mg',
      descricao: 'Termogênico voltado para energia e emagrecimento.',
      preco: 19.90,
      categoria: 'EMAGRECEDORES',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'Thermo Pro Hard 400mg',
      descricao: 'Termogênico para auxiliar na queima de gordura e disposição.',
      preco: 24.90,
      categoria: 'EMAGRECEDORES',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'L-Carnitine Reload',
      descricao: 'L-carnitina para auxiliar no metabolismo energético.',
      preco: 29.90,
      categoria: 'EMAGRECEDORES',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'Testo Hard GH - 60 tabletes',
      descricao: 'Suplemento específico para suporte hormonal e performance.',
      preco: 30.90,
      categoria: 'ESPECÍFICOS',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'ZMA Up - 90 cápsulas',
      descricao: 'ZMA com minerais para suporte muscular e recuperação.',
      preco: 25.90,
      categoria: 'ESPECÍFICOS',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'Hipercalórico Anabolic Gainer Mass 3kg',
      descricao: 'Hipercalórico para ganho de peso e massa muscular.',
      preco: 72.90,
      categoria: 'ESPECÍFICOS',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'Vit-Full - 90 cápsulas',
      descricao: 'Multivitamínico para suporte à saúde e imunidade.',
      preco: 25.90,
      categoria: 'VITAMINAS',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'Dilaton Pump - 120 cápsulas',
      descricao: 'Vasodilatador para auxiliar no pump e desempenho muscular.',
      preco: 42.90,
      categoria: 'PRÉ-TREINOS',
      imagem: '',
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
      descricao: 'Kit para suporte à hipertrofia e evolução muscular.',
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
      descricao: 'Kit completo para performance, energia e recuperação.',
      preco: 260.90,
      categoria: 'KIT PRONTO',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'Camiseta Dry Fit Never Lose Your Way',
      descricao: 'Camiseta dry fit confortável para treino e uso diário.',
      preco: 39.90,
      categoria: 'ACESSÓRIOS',
      imagem: '',
    ),
    ProdutoModel(
      nome: 'Coqueteleira Muscleway - 600ml',
      descricao: 'Coqueteleira de 600ml para preparo de suplementos.',
      preco: 15.90,
      categoria: 'ACESSÓRIOS',
      imagem: '',
    ),
  ];
}
