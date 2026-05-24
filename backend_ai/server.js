import http from 'node:http';
import { existsSync, readFileSync } from 'node:fs';

function carregarEnvLocal() {
  if (!existsSync('.env')) return;

  const linhas = readFileSync('.env', 'utf8').split(/\r?\n/);

  for (const linha of linhas) {
    const limpa = linha.trim();
    if (!limpa || limpa.startsWith('#')) continue;

    const separador = limpa.indexOf('=');
    if (separador === -1) continue;

    const chave = limpa.slice(0, separador).trim();
    const valor = limpa.slice(separador + 1).trim();

    if (!process.env[chave]) {
      process.env[chave] = valor;
    }
  }
}

carregarEnvLocal();

const port = Number(process.env.PORT || 3001);
const apiKey = process.env.OPENAI_API_KEY;
const model = process.env.OPENAI_MODEL || 'gpt-4.1-mini';

function sendJson(response, statusCode, data) {
  response.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
  });
  response.end(JSON.stringify(data));
}

function readBody(request) {
  return new Promise((resolve, reject) => {
    let body = '';

    request.on('data', (chunk) => {
      body += chunk;
      if (body.length > 100_000) {
        request.destroy();
        reject(new Error('Payload muito grande.'));
      }
    });

    request.on('end', () => resolve(body));
    request.on('error', reject);
  });
}

function montarContextoCatalogo(produtos) {
  return produtos
    .map((produto) => {
      return `- ${produto.nome} | ${produto.categoria} | R$ ${Number(produto.preco).toFixed(2)} | ${produto.descricao}`;
    })
    .join('\n');
}

async function consultarOpenAI({ pergunta, produtos }) {
  if (!apiKey) {
    throw new Error('OPENAI_API_KEY não configurada no backend.');
  }

  const catalogo = montarContextoCatalogo(produtos || []);

  const response = await fetch('https://api.openai.com/v1/responses', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model,
      max_output_tokens: 450,
      instructions:
        'Você é o consultor Muscleway IA dentro de um app de suplementos. Responda em português do Brasil, seja direto, comercial e responsável. Sugira apenas produtos presentes no catálogo enviado. Nunca prometa cura ou resultado médico. Sempre recomende procurar um profissional de saúde em caso de restrições, doenças, gestação ou uso de medicamentos.',
      input: `Catálogo disponível:\n${catalogo}\n\nPergunta do cliente: ${pergunta}`,
    }),
  });

  const data = await response.json();

  if (!response.ok) {
    const message = data?.error?.message || 'Erro ao consultar a OpenAI.';
    throw new Error(message);
  }

  if (typeof data.output_text === 'string' && data.output_text.trim()) {
    return data.output_text.trim();
  }

  const text = data.output
    ?.flatMap((item) => item.content || [])
    ?.map((content) => content.text)
    ?.filter(Boolean)
    ?.join('\n')
    ?.trim();

  return text || 'Não consegui gerar uma resposta agora. Tente reformular sua pergunta.';
}

const server = http.createServer(async (request, response) => {
  if (request.method === 'OPTIONS') {
    return sendJson(response, 200, { ok: true });
  }

  if (request.method === 'GET' && request.url === '/health') {
    return sendJson(response, 200, {
      ok: true,
      model,
      apiKeyConfigured: Boolean(apiKey),
    });
  }

  if (request.method !== 'POST' || request.url !== '/chat') {
    return sendJson(response, 404, { error: 'Rota não encontrada.' });
  }

  try {
    const body = await readBody(request);
    const payload = JSON.parse(body || '{}');

    if (!payload.pergunta || typeof payload.pergunta !== 'string') {
      return sendJson(response, 400, { error: 'Campo pergunta é obrigatório.' });
    }

    const resposta = await consultarOpenAI(payload);
    return sendJson(response, 200, { resposta });
  } catch (error) {
    return sendJson(response, 500, {
      error: error instanceof Error ? error.message : 'Erro inesperado.',
    });
  }
});

server.listen(port, () => {
  console.log(`Muscleway AI backend rodando em http://localhost:${port}`);
  console.log(`Modelo: ${model}`);
  console.log(`Chave configurada: ${apiKey ? 'sim' : 'não'}`);
});
