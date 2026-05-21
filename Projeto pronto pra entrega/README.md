# Muscleway - Projeto Final

Este repositório é uma cópia documentada do aplicativo Muscleway, criada para
organizar a entrega acadêmica sem alterar o Git principal.

## O que é o projeto

Muscleway é um aplicativo Flutter de e-commerce de suplementos com:

- login e cadastro;
- catálogo de produtos;
- busca e filtro por categoria;
- tela de detalhes;
- carrinho de compras;
- consultor de IA para sugerir suplementos;
- backend local em Dart para integração segura com a API da OpenAI.

## Onde está o aplicativo

O app Flutter real está em:

```text
app_muscley/
```

## Como rodar o app

```bash
cd app_muscley
flutter pub get
flutter run
```

## Como rodar a IA real

Em outro terminal:

```bash
cd app_muscley/backend_ai
copy .env.example .env
dart server.dart
```

Edite o `.env` e coloque sua chave:

```text
OPENAI_API_KEY=sua_chave_aqui
OPENAI_MODEL=gpt-4.1-mini
PORT=3001
```

## Documentação

A pasta `docs/` contém os requisitos, casos de uso, backlog, visão de produto
e diagramas explicativos do projeto.
