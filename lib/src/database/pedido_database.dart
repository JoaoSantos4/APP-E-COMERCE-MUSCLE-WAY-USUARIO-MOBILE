import 'package:pi/src/models/carrinho_item_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class PedidoDatabase {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'muscleway_pedidos.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pedidos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            usuario_email TEXT NOT NULL,
            usuario_nome TEXT NOT NULL,
            endereco TEXT NOT NULL,
            pagamento TEXT NOT NULL,
            cupom TEXT,
            subtotal REAL NOT NULL,
            desconto REAL NOT NULL,
            total REAL NOT NULL,
            criado_em TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE pedido_itens(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pedido_id INTEGER NOT NULL,
            produto_nome TEXT NOT NULL,
            produto_imagem TEXT NOT NULL,
            quantidade INTEGER NOT NULL,
            preco_unitario REAL NOT NULL,
            subtotal REAL NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  static Future<int> cadastrarPedido({
    required String usuarioEmail,
    required String usuarioNome,
    required String endereco,
    required String pagamento,
    required String cupom,
    required double subtotal,
    required double desconto,
    required double total,
    required List<CarrinhoItemModel> itens,
  }) async {
    final db = await getDatabase();

    return db.transaction((txn) async {
      final pedidoId = await txn.insert('pedidos', {
        'usuario_email': usuarioEmail,
        'usuario_nome': usuarioNome,
        'endereco': endereco,
        'pagamento': pagamento,
        'cupom': cupom,
        'subtotal': subtotal,
        'desconto': desconto,
        'total': total,
        'criado_em': DateTime.now().toIso8601String(),
      });

      for (final item in itens) {
        await txn.insert('pedido_itens', {
          'pedido_id': pedidoId,
          'produto_nome': item.produto.nome,
          'produto_imagem': item.produto.imagem,
          'quantidade': item.quantidade,
          'preco_unitario': item.produto.preco,
          'subtotal': item.subtotal,
        });
      }

      return pedidoId;
    });
  }

  static Future<List<Map<String, dynamic>>> listarPedidos({
    String? usuarioEmail,
  }) async {
    final db = await getDatabase();

    if (usuarioEmail == null) {
      return db.query('pedidos', orderBy: 'id DESC');
    }

    return db.query(
      'pedidos',
      where: 'usuario_email = ?',
      whereArgs: [usuarioEmail],
      orderBy: 'id DESC',
    );
  }

  static Future<List<Map<String, dynamic>>> listarItens(int pedidoId) async {
    final db = await getDatabase();

    return db.query(
      'pedido_itens',
      where: 'pedido_id = ?',
      whereArgs: [pedidoId],
      orderBy: 'id',
    );
  }
}
