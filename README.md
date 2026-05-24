# Muscleway

Aplicativo Flutter de catálogo de suplementos com login, cadastro, busca,
produtos, carrinho de compras e consultor de IA.

## Destaques

- Identidade visual premium em preto, branco e azul bebê.
- Home com campanha de destaque, benefícios de compra, busca e departamentos.
- Cards de produto com preço no Pix, preço no cartão, categoria e CTA claro.
- Página de produto com resumo comercial, desconto no Pix e benefícios.
- Carrinho com barra de frete grátis, resumo de checkout e finalização.
- Aba exclusiva de IA para sugerir suplementos por objetivo do cliente.
- Login, cadastro, sessão do usuário e banco local com SQLite.

## Como rodar

```bash
flutter pub get
flutter run
```

## Como rodar a IA real

Nunca coloque a chave da OpenAI dentro do app Flutter. Use o backend local:

```bash
cd backend_ai
copy .env.example .env
```

Edite `backend_ai/.env` e coloque sua chave:

```text
OPENAI_API_KEY=sua_chave_aqui
OPENAI_MODEL=gpt-4.1-mini
PORT=3001
```

Depois rode o backend com Dart:

```bash
dart server.dart
```

Em outro terminal, rode o app no emulador Android:

```bash
flutter run -d emulator-5554
```

Se mudar a porta do backend, passe a URL para o Flutter:

```bash
flutter run -d emulator-5554 --dart-define=AI_BACKEND_URL=http://10.0.2.2:3001
```

## Verificação

```bash
flutter analyze
flutter test
flutter build apk --debug
```
