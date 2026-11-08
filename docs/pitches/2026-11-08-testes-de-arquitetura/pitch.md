# Testes de arquitetura no backend

Estado: shaping
Apetite: a definir

## Problema

As regras de arquitetura do backend não são conferidas por teste, e um agente pode quebrá-las sem perceber. A mais importante vem do produto: um tenant nunca pode ver dados de outro (`docs/PRODUCT_SENSE.md`), então nenhum acesso a dados pode escapar do filtro de tenant.

Origem: ficou fora de escopo em `2026-11-07-sensores-computacionais` ("fitness functions de arquitetura (Spring Modulith, ArchUnit)"), em `docs/historico/exec-plans/`.

**Este pitch espera o primeiro módulo de produto.** As regras dependem de como os módulos e o acesso a dados forem desenhados, e hoje o backend só tem `BackendApplication`, um teste de health e os sensores de comentário. Dar forma antes disso seria inventar a arquitetura dentro do pitch de testes.

## Solução

O que precisa sair, como estava no rascunho:

- Ferramenta escolhida e no `pom.xml`. Candidatos já citados: ArchUnit e Spring Modulith.
- Cada regra de arquitetura decidida no shaping tem um teste que falha quando a regra é quebrada, com mensagem que diz como corrigir. Comprovado quebrando cada regra de propósito.
- Uma regra impede acesso a dados sem o filtro de tenant. Comprovado com um acesso sem tenant de propósito.
- `scripts/verify.sh` passa local e no CI.

## Protótipo

Sem interface.

## Rabbit holes

- Toda dependência nova segue a regra da skill `executar`.
- O backend já tem testes de sensor em `backend/src/test/java/com/desfecha/sensores/`, que servem de modelo.

## No-gos

- Desenhar os módulos de produto: vêm de outro pitch.
- Regras de arquitetura no frontend.

## Revisão do protótipo

Sem protótipo.

## Log de decisões

- **D1. Convertido do exec-plan em rascunho `2026-11-08-testes-de-arquitetura` (2026-11-08):** pelo exec-plan `2026-11-08-shape-up` (em `docs/historico/exec-plans/`). Critérios de aceite e passos viraram a solução; o apetite e as perguntas em aberto ficam para o shaping.

## Perguntas em aberto

- Quais módulos e camadas existem, e quais dependências entre eles são proibidas? Depende do primeiro módulo de produto.
- Como o tenant é aplicado no acesso a dados (filtro no repositório, schema por tenant, row-level security)? Essa é uma decisão de produto e arquitetura, anterior a este pitch.
