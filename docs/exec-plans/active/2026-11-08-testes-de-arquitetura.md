# Testes de arquitetura no backend

Status: rascunho

## Objetivo

Regras de arquitetura do backend conferidas por teste, para que um agente não as quebre sem perceber. A mais importante vem do produto: um tenant nunca pode ver dados de outro (`docs/PRODUCT_SENSE.md`), então nenhum acesso a dados pode escapar do filtro de tenant.

## Contexto

- Origem: ficou fora de escopo em `2026-11-07-sensores-computacionais` ("fitness functions de arquitetura (Spring Modulith, ArchUnit)").
- **Este rascunho espera o primeiro módulo de produto.** As regras dependem de como os módulos e o acesso a dados forem desenhados, e hoje o backend só tem `BackendApplication`, um teste de health e os sensores de comentário. Refinar antes disso seria inventar a arquitetura dentro do plano de testes.
- Candidatos já citados: ArchUnit e Spring Modulith. Toda dependência nova segue a regra da skill `executar`.
- O backend já tem testes de sensor em `backend/src/test/java/com/desfecha/sensores/`, que servem de modelo.

## Critérios de aceite

- [ ] Cada regra de arquitetura decidida no refinamento tem um teste que falha quando a regra é quebrada, com mensagem que diz como corrigir. Comprovado quebrando cada regra de propósito.
- [ ] Existe uma regra que impede acesso a dados sem o filtro de tenant. Comprovado com um acesso sem tenant de propósito.
- [ ] `scripts/verify.sh` passa local e no CI.

## Fora de escopo

- Desenhar os módulos de produto: vêm de outra tarefa.
- Regras de arquitetura no frontend.

## Passos

- [ ] Ferramenta escolhida e no `pom.xml`
- [ ] Regras e testes

## Log de progresso

- 2026-11-08: rascunho criado. Espera o primeiro módulo de produto para ser refinado.

## Log de decisões

## Perguntas em aberto

- Quais módulos e camadas existem, e quais dependências entre eles são proibidas? Depende do primeiro módulo de produto.
- Como o tenant é aplicado no acesso a dados (filtro no repositório, schema por tenant, row-level security)? Essa é uma decisão de produto e arquitetura, anterior a este plano.
