// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final env = _carregarEnv();
  final port = int.tryParse(env['PORT'] ?? '3001') ?? 3001;
  final apiKey = env['OPENAI_API_KEY'];
  final model = env['OPENAI_MODEL'] ?? 'gpt-4.1-mini';

  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);

  print('Muscleway AI backend rodando em http://localhost:$port');
  print('Modelo: $model');
  print(
    'Chave configurada: ${apiKey == null || apiKey.isEmpty ? 'não' : 'sim'}',
  );

  await for (final request in server) {
    await _handleRequest(request, apiKey: apiKey, model: model);
  }
}

Future<void> _handleRequest(
  HttpRequest request, {
  required String? apiKey,
  required String model,
}) async {
  _setCorsHeaders(request.response);

  if (request.method == 'OPTIONS') {
    await _sendJson(request.response, 200, {'ok': true});
    return;
  }

  if (request.method == 'GET' && request.uri.path == '/health') {
    await _sendJson(request.response, 200, {
      'ok': true,
      'model': model,
      'apiKeyConfigured': apiKey != null && apiKey.isNotEmpty,
    });
    return;
  }

  if (request.method != 'POST' || request.uri.path != '/chat') {
    await _sendJson(request.response, 404, {'error': 'Rota não encontrada.'});
    return;
  }

  try {
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY não configurada no arquivo .env.');
    }

    final body = await utf8.decoder.bind(request).join();
    final payload = jsonDecode(body) as Map<String, dynamic>;
    final pergunta = payload['pergunta'];
    final produtos = payload['produtos'];

    if (pergunta is! String || pergunta.trim().isEmpty) {
      await _sendJson(request.response, 400, {
        'error': 'Campo pergunta é obrigatório.',
      });
      return;
    }

    final resposta = await _consultarOpenAI(
      apiKey: apiKey,
      model: model,
      pergunta: pergunta,
      produtos: produtos is List ? produtos : const [],
    );

    await _sendJson(request.response, 200, {'resposta': resposta});
  } catch (error) {
    await _sendJson(request.response, 500, {'error': error.toString()});
  }
}

Future<String> _consultarOpenAI({
  required String apiKey,
  required String model,
  required String pergunta,
  required List<dynamic> produtos,
}) async {
  final catalogo = produtos
      .map((produto) {
        if (produto is! Map) return '';

        final nome = produto['nome'] ?? '';
        final categoria = produto['categoria'] ?? '';
        final preco = produto['preco'] ?? '';
        final descricao = produto['descricao'] ?? '';

        return '- $nome | $categoria | R\$ $preco | $descricao';
      })
      .where((linha) => linha.isNotEmpty)
      .join('\n');

  final client = HttpClient();
  final request = await client.postUrl(
    Uri.parse('https://api.openai.com/v1/responses'),
  );

  request.headers.contentType = ContentType.json;
  request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');

  request.write(
    jsonEncode({
      'model': model,
      'max_output_tokens': 450,
      'instructions':
          'Você é o consultor Muscleway IA dentro de um app de suplementos. Responda em português do Brasil, seja direto, comercial e responsável. Sugira apenas produtos presentes no catálogo enviado. Nunca prometa cura ou resultado médico. Sempre recomende procurar um profissional de saúde em caso de restrições, doenças, gestação ou uso de medicamentos.',
      'input':
          'Catálogo disponível:\n$catalogo\n\nPergunta do cliente: $pergunta',
    }),
  );

  final response = await request.close();
  final responseBody = await utf8.decoder.bind(response).join();
  client.close(force: true);

  final data = jsonDecode(responseBody) as Map<String, dynamic>;

  if (response.statusCode < 200 || response.statusCode >= 300) {
    final error = data['error'];
    if (error is Map && error['message'] is String) {
      throw Exception(error['message']);
    }
    throw Exception('Erro ao consultar a OpenAI.');
  }

  final outputText = data['output_text'];
  if (outputText is String && outputText.trim().isNotEmpty) {
    return outputText.trim();
  }

  final output = data['output'];
  if (output is List) {
    final textos = <String>[];

    for (final item in output) {
      if (item is! Map) continue;
      final content = item['content'];
      if (content is! List) continue;

      for (final bloco in content) {
        if (bloco is Map && bloco['text'] is String) {
          textos.add(bloco['text'] as String);
        }
      }
    }

    if (textos.isNotEmpty) return textos.join('\n').trim();
  }

  return 'Não consegui gerar uma resposta agora. Tente reformular sua pergunta.';
}

Map<String, String> _carregarEnv() {
  final env = Map<String, String>.from(Platform.environment);
  final scriptDir = File.fromUri(Platform.script).parent;
  final candidates = [
    File('.env'),
    File('${scriptDir.path}${Platform.pathSeparator}.env'),
  ];

  for (final file in candidates) {
    if (!file.existsSync()) continue;

    for (final line in file.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

      final separator = trimmed.indexOf('=');
      if (separator == -1) continue;

      final key = trimmed.substring(0, separator).trim();
      final value = trimmed.substring(separator + 1).trim();
      env.putIfAbsent(key, () => value);
    }
  }

  return env;
}

void _setCorsHeaders(HttpResponse response) {
  response.headers.set('Access-Control-Allow-Origin', '*');
  response.headers.set('Access-Control-Allow-Headers', 'Content-Type');
  response.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
}

Future<void> _sendJson(
  HttpResponse response,
  int statusCode,
  Map<String, dynamic> data,
) async {
  response.statusCode = statusCode;
  response.headers.contentType = ContentType.json;
  response.write(jsonEncode(data));
  await response.close();
}
