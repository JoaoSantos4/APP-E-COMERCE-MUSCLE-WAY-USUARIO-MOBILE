# core/errors

Camada destinada a erros e exceções do projeto.

Exemplos:

- erro de login inválido;
- erro de e-mail já cadastrado;
- erro de conexão com backend IA;
- erro de resposta da OpenAI;
- erro ao carregar produtos do SQLite.

No código atual, parte desses erros ainda é tratada diretamente nas telas e
services. Em uma próxima refatoração, poderiam ser centralizados aqui.
