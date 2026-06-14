Um aplicativo Flutter de e-commerce de suplementos com login, cadastro, catalogo de produtos, busca, carrinho de compras e consultor de IA.

## Recursos principais

- Login, cadastro e sessao do usuario.
- Catalogo de suplementos com categorias e busca.
- Pagina de produto com preco, desconto no Pix e detalhes comerciais.
- Carrinho de compras com resumo do pedido.
- Banco local SQLite para usuarios e produtos.
- Consultor de IA com backend local para recomendacoes de suplementos.

## Requisitos

- Flutter SDK instalado.
- Dart SDK, normalmente ja incluso no Flutter.
- Emulador Android, dispositivo fisico ou navegador para rodar o app.
- Node.js 18+ ou Dart para executar o backend de IA.

## Como executar o app

Na raiz do projeto, rode:

```bash
flutter pub get
flutter run
```

Para escolher um dispositivo especifico:

```bash
flutter devices
flutter run -d <id-do-dispositivo>
```

## Como executar o backend de IA

O app funciona com uma resposta local de fallback, mas para usar IA real rode o backend local.

Crie o arquivo de ambiente:

```bash
cd backend_ai
copy .env.example .env
```

Edite `backend_ai/.env` e preencha:

```text
OPENAI_API_KEY=sua_chave_aqui
OPENAI_MODEL=gpt-4.1-mini
PORT=3001
```

Depois execute o backend com uma das opcoes abaixo.

Com Node.js:

```bash
npm install
npm start
```

Ou com Dart:

```bash
dart server.dart
```

Em outro terminal, volte para a raiz do projeto e rode o app:

```bash
flutter run
```

No emulador Android, a URL padrao do backend deve ser `http://10.0.2.2:3001`. Se precisar informar manualmente:

```bash
flutter run -d emulator-5554 --dart-define=AI_BACKEND_URL=http://10.0.2.2:3001
```

Para Chrome ou Windows, use localhost:

```bash
flutter run -d chrome --dart-define=AI_BACKEND_URL=http://localhost:3001
```

## Verificacao

```bash
flutter analyze
flutter test
flutter build apk --debug
```
