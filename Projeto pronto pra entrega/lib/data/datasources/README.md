# data/datasources

Camada para fontes de dados.

No Muscleway existem duas fontes principais:

1. SQLite local, usado por `UsuarioDatabase` e `ProdutoDatabase`.
2. Backend IA, usado pelo `AssistenteSuplementosService`.

Em uma arquitetura mais limpa, os arquivos de banco e chamadas HTTP ficariam
centralizados nesta pasta.
