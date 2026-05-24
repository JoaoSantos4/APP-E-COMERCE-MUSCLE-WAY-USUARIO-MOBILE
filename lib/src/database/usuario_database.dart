import 'dart:convert';

import 'package:pi/src/controllers/sessao_controller.dart';
import 'package:pi/src/models/usuario_model.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UsuarioDatabase {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'muscleway.db');

    _database = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _criarTabelaUsuarios(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE usuarios ADD COLUMN tipo_usuario TEXT NOT NULL DEFAULT 'cliente'",
          );
        }
      },
    );

    await garantirAdminPadrao();
    return _database!;
  }

  static Future<void> _criarTabelaUsuarios(Database db) async {
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha_hash TEXT NOT NULL,
        tipo_usuario TEXT NOT NULL DEFAULT 'cliente'
      )
    ''');
  }

  static String gerarHash(String senha) {
    return sha256.convert(utf8.encode(senha)).toString();
  }

  static Future<void> garantirAdminPadrao() async {
    final db = _database ?? await getDatabase();
    final email = SessaoController.adminEmail;
    final resultado = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (resultado.isEmpty) {
      await db.insert('usuarios', {
        'nome': 'Administrador',
        'email': email,
        'senha_hash': gerarHash('12345678'),
        'tipo_usuario': 'admin',
      });
      return;
    }

    await db.update(
      'usuarios',
      {'tipo_usuario': 'admin'},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  static Future<bool> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
    String tipoUsuario = 'cliente',
  }) async {
    try {
      final db = await getDatabase();
      final emailNormalizado = email.trim().toLowerCase();

      final usuarioExistente = await db.query(
        'usuarios',
        where: 'email = ?',
        whereArgs: [emailNormalizado],
      );

      if (usuarioExistente.isNotEmpty) {
        return false;
      }

      final usuario = UsuarioModel(
        nome: nome.trim(),
        email: emailNormalizado,
        senhaHash: gerarHash(senha),
        tipoUsuario: tipoUsuario,
      );

      await db.insert('usuarios', usuario.toMap());

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> login({
    required String email,
    required String senha,
  }) async {
    final usuario = await buscarUsuarioPorLogin(email: email, senha: senha);
    return usuario != null;
  }

  static Future<List<UsuarioModel>> listarUsuarios() async {
    final db = await getDatabase();
    final resultado = await db.query('usuarios', orderBy: 'id DESC');

    return resultado.map(UsuarioModel.fromMap).toList();
  }

  static Future<void> excluirUsuario(int id) async {
    final db = await getDatabase();
    await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }

  static Future<UsuarioModel?> buscarUsuarioPorLogin({
    required String email,
    required String senha,
  }) async {
    final db = await getDatabase();
    final emailNormalizado = email.trim().toLowerCase();

    final resultado = await db.query(
      'usuarios',
      where: 'email = ? AND senha_hash = ?',
      whereArgs: [emailNormalizado, gerarHash(senha)],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return UsuarioModel.fromMap(resultado.first);
  }
}
