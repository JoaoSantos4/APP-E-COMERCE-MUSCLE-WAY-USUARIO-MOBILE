# Requisitos Não Funcionais

## RNF01 - Segurança da chave de IA

A chave da OpenAI não deve ficar no aplicativo Flutter. Ela deve ficar somente no
backend local, no arquivo `.env`, que não é enviado ao GitHub.

## RNF02 - Usabilidade

As telas devem ser simples de entender, com botões claros e fluxo direto para
login, catálogo, carrinho e consultor de IA.

## RNF03 - Visual

O app deve manter uma identidade visual consistente usando preto, branco e azul
bebê, com aparência de loja esportiva.

## RNF04 - Desempenho

O catálogo e o carrinho devem responder rapidamente, pois usam dados locais.

## RNF05 - Disponibilidade parcial

Mesmo se a API da OpenAI estiver indisponível, o chat deve continuar respondendo
com o fallback local.

## RNF06 - Manutenibilidade

O código deve ser separado em páginas, modelos, banco de dados, controllers,
services, widgets e tema.

## RNF07 - Portabilidade

O app deve rodar em emulador Android e pode ser adaptado para outras plataformas
Flutter.

## RNF08 - Integridade dos dados

O cadastro deve evitar e-mails duplicados e armazenar senha com hash, sem salvar
a senha em texto puro.
