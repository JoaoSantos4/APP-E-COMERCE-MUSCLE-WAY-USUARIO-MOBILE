# Casos de Uso

## CU01 - Criar conta

**Ator:** usuário.  
**Objetivo:** cadastrar-se no app Muscleway.

### Fluxo principal

1. Usuário abre a tela de cadastro.
2. Informa nome, e-mail e senha.
3. Confirma a senha.
4. Sistema valida os dados.
5. Sistema salva o usuário no SQLite.
6. Usuário volta para o login.

### Exceções

- E-mail inválido.
- Senha com menos de 8 caracteres.
- E-mail já cadastrado.
- Senhas diferentes.

## CU02 - Fazer login

**Ator:** usuário.  
**Objetivo:** acessar a loja.

### Fluxo principal

1. Usuário informa e-mail e senha.
2. Sistema busca o usuário no banco local.
3. Sistema compara o hash da senha.
4. Usuário entra na Home.

## CU03 - Buscar produto

**Ator:** usuário.  
**Objetivo:** encontrar suplementos no catálogo.

### Fluxo principal

1. Usuário digita um termo no campo de busca.
2. Sistema filtra por nome, descrição e categoria.
3. Sistema exibe os produtos correspondentes.

## CU04 - Adicionar produto ao carrinho

**Ator:** usuário.  
**Objetivo:** montar uma compra.

### Fluxo principal

1. Usuário toca em adicionar ao carrinho.
2. Sistema adiciona o produto ao CarrinhoController.
3. Sistema atualiza quantidade e valor total.
4. Usuário visualiza o carrinho.

## CU05 - Consultar IA

**Ator:** usuário.  
**Objetivo:** receber sugestão de suplementos.

### Fluxo principal

1. Usuário abre a tela Consultor IA.
2. Digita uma pergunta, como "quero ganhar massa".
3. App envia pergunta e catálogo para o backend.
4. Backend chama a OpenAI.
5. IA responde com sugestões de produtos.
6. App exibe a resposta no chat.

### Fluxo alternativo

Se a API falhar, o app usa o fallback local baseado em palavras-chave.
