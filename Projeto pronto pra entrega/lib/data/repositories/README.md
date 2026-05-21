# data/repositories

Camada para repositórios.

Um repositório funciona como intermediário entre as telas/controllers e as
fontes de dados.

Exemplos que poderiam existir:

- `ProdutoRepository`, usando `ProdutoDatabase`;
- `UsuarioRepository`, usando `UsuarioDatabase`;
- `IaRepository`, usando o backend IA e fallback local.

Isso facilitaria testes e manutenção futura.
