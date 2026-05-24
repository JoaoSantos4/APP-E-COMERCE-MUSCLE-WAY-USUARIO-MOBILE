import 'dart:convert';

import 'package:pi/src/models/produto_model.dart';
import 'package:http/http.dart' as http;

class AssistenteSuplementosService {
  static const String _backendUrl = String.fromEnvironment(
    'AI_BACKEND_URL',
    defaultValue: 'http://10.0.2.2:3001',
  );

  static Future<String> responder({
    required String pergunta,
    required List<ProdutoModel> produtos,
  }) async {
    final respostaApi = await _responderComOpenAI(
      pergunta: pergunta,
      produtos: produtos,
    );

    if (respostaApi != null) {
      return respostaApi;
    }

    return responderLocal(pergunta: pergunta, produtos: produtos);
  }

  static Future<String?> _responderComOpenAI({
    required String pergunta,
    required List<ProdutoModel> produtos,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_backendUrl/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'pergunta': pergunta,
              'produtos': produtos.map((produto) => produto.toMap()).toList(),
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final resposta = data['resposta'];

      if (resposta is String && resposta.trim().isNotEmpty) {
        return resposta.trim();
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static String responderLocal({
    required String pergunta,
    required List<ProdutoModel> produtos,
  }) {
    final texto = pergunta.toLowerCase();

    if (texto.trim().isEmpty) {
      return 'Me conte seu objetivo: ganhar massa, emagrecer, ter mais energia, recuperar melhor ou montar um kit Muscleway.';
    }

    final sugestoes = _filtrarProdutos(texto, produtos).take(3).toList();

    if (sugestoes.isEmpty) {
      return 'A IA real nÃ£o respondeu agora e nÃ£o encontrei uma sugestÃ£o exata no catÃ¡logo local. Tente algo como: "quero ganhar massa", "quero emagrecer" ou "preciso de energia para treino".';
    }

    final objetivo = _identificarObjetivo(texto);
    final buffer = StringBuffer()
      ..writeln('A IA real nÃ£o respondeu agora, entÃ£o usei o consultor local.')
      ..writeln()
      ..writeln('Para $objetivo, eu olharia estes produtos:')
      ..writeln();

    for (final produto in sugestoes) {
      buffer.writeln(
        '- ${produto.nome} (${_formatarPreco(produto.preco)}): ${produto.descricao}',
      );
    }

    buffer
      ..writeln()
      ..write(
        'Dica: confira a descriÃ§Ã£o e escolha de acordo com seu objetivo. Se tiver restriÃ§Ã£o mÃ©dica, use orientaÃ§Ã£o profissional.',
      );

    return buffer.toString();
  }

  static List<ProdutoModel> _filtrarProdutos(
    String texto,
    List<ProdutoModel> produtos,
  ) {
    if (_contem(texto, ['massa', 'hipertrofia', 'ganhar peso', 'peso'])) {
      return _porTermos(produtos, ['whey', 'protein', 'hipercalÃ³rico', 'kit']);
    }
    if (_contem(texto, ['emagrecer', 'emagrecimento', 'queima', 'gordura'])) {
      return _porTermos(produtos, ['thermo', 'carnitine', 'emagrecedor']);
    }
    if (_contem(texto, ['energia', 'foco', 'treino', 'prÃ© treino'])) {
      return _porTermos(produtos, ['beta', 'prÃ©-treino', 'performance']);
    }
    if (_contem(texto, ['recuperaÃ§Ã£o', 'recuperar', 'dor', 'amino'])) {
      return _porTermos(produtos, ['bcaa', 'glutamine', 'creatine']);
    }
    if (_contem(texto, ['imunidade', 'vitamina', 'saÃºde'])) {
      return _porTermos(produtos, ['vit', 'imunidade']);
    }
    if (_contem(texto, ['kit', 'combo', 'conjunto'])) {
      return produtos
          .where((produto) => produto.categoria.toLowerCase().contains('kit'))
          .toList();
    }

    return produtos.where((produto) {
      final base = '${produto.nome} ${produto.descricao} ${produto.categoria}'
          .toLowerCase();
      return texto
          .split(' ')
          .where((palavra) => palavra.length > 3)
          .any(base.contains);
    }).toList();
  }

  static List<ProdutoModel> _porTermos(
    List<ProdutoModel> produtos,
    List<String> termos,
  ) {
    return produtos.where((produto) {
      final base = '${produto.nome} ${produto.descricao} ${produto.categoria}'
          .toLowerCase();
      return termos.any(base.contains);
    }).toList();
  }

  static String _identificarObjetivo(String texto) {
    if (_contem(texto, ['massa', 'hipertrofia', 'ganhar peso', 'peso'])) {
      return 'ganho de massa';
    }
    if (_contem(texto, ['emagrecer', 'emagrecimento', 'queima', 'gordura'])) {
      return 'emagrecimento';
    }
    if (_contem(texto, ['energia', 'foco', 'treino', 'prÃ© treino'])) {
      return 'mais energia no treino';
    }
    if (_contem(texto, ['recuperaÃ§Ã£o', 'recuperar', 'dor', 'amino'])) {
      return 'recuperaÃ§Ã£o muscular';
    }
    if (_contem(texto, ['imunidade', 'vitamina', 'saÃºde'])) {
      return 'saÃºde e imunidade';
    }
    return 'seu objetivo';
  }

  static bool _contem(String texto, List<String> termos) {
    return termos.any(texto.contains);
  }

  static String _formatarPreco(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

