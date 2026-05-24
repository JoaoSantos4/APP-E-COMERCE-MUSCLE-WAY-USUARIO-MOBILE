import 'dart:convert';

import 'package:app_muscley/src/models/usuario_model.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UsuarioDatabase {
  static Database? _database;

  // =========================
  // INICIAR BANCO
  // =========================

  static Future<Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    final databasePath = await getDatabasesPath();

    final path = join(databasePath, 'muscleway.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE usuarios(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            senha_hash TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  // =========================
  // GERAR HASH
  // =========================

  static String gerarHash(String senha) {
    return sha256.convert(utf8.encode(senha)).toString();
  }

  static Future<bool> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
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
