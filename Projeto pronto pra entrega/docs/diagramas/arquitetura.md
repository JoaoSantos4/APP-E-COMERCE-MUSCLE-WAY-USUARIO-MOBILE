# Diagrama de Arquitetura

```mermaid
flowchart TD
    Usuario["Usuário"] --> Flutter["App Flutter Muscleway"]
    Flutter --> SQLite["SQLite local"]
    Flutter --> Carrinho["CarrinhoController"]
    Flutter --> Chat["Tela Consultor IA"]
    Chat --> Backend["Backend IA em Dart"]
    Backend --> OpenAI["OpenAI Responses API"]
    OpenAI --> Backend
    Backend --> Chat
    Chat --> Fallback["Fallback local por palavras-chave"]
```

## Explicação

O aplicativo Flutter concentra a interface e as regras principais do app. O
SQLite guarda usuários e produtos. O carrinho fica em memória por meio do
CarrinhoController. A tela de IA chama o backend local, que consulta a OpenAI.
Caso o backend ou a API falhe, o app usa o fallback local.
