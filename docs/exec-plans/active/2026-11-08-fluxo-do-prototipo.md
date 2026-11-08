# Fluxo do protótipo: como uma tela é feita e revisada

Status: rascunho

## Objetivo

Definir o fluxo pelo qual os agentes constroem o protótipo. A skill `executar` não serve para isso: ela foi feita para código, com TDD, um plano fechado e um PR por tarefa. O protótipo é exploração, com revisão de UX/UI a cada tela. Sem um fluxo escrito, cada sessão inventa o seu, e as decisões de produto e de interface que saem de uma tela se perdem na conversa.

## Contexto

- `prototipo/README.md` já tem as regras do protótipo: sem build e sem dependências, o `frontend/` não importa nada dele, toda tela entra na lista do `index.html`, e marca, fontes e cores viram variáveis em `prototipo/estilo.css`, com a decisão num tema de `docs/produto/`.
- Decisões de produto que saem de uma tela vão para o tema certo de `docs/produto/`, como a skill `refinar` já faz para os planos.
- A checagem de tela sem link a partir do `index.html` (sugestão da revisão do PR #4) não é uma tarefa à parte: nasce junto com as primeiras telas, dentro deste fluxo.
- A troca de fase do `AGENTS.md` ("Base do harness") para a de produto é decisão do humano e precisa estar escrita lá antes da primeira tela.

## Critérios de aceite

- [ ] Existe um fluxo escrito (skill em `.claude/skills/` ou documento em `prototipo/`, decidido no refinamento) que diz como uma tela começa, quem revisa UX/UI e com quais critérios, como ela é comprovada e onde ficam as decisões. Comprovado lendo o arquivo.
- [ ] O `AGENTS.md` aponta para o fluxo. Comprovado lendo o arquivo.
- [ ] `scripts/verify.sh` passa local e no CI.

## Fora de escopo

- Construir telas.
- Definir marca, fontes e cores.
- Mudar a skill `executar`.

## Passos

- [ ] Fluxo escrito
- [ ] `AGENTS.md`

## Log de progresso

- 2026-11-08: rascunho criado.

## Log de decisões

## Perguntas em aberto

- A unidade de trabalho do protótipo é a tela, o fluxo de telas ou uma sessão de exploração? Ela tem exec-plan?
- A revisão de UX/UI é feita por um agente revisor (com quais critérios e heurísticas), pelo humano, ou pelos dois?
- Como uma tela é comprovada: screenshot no navegador, checagem de acessibilidade, as duas?
- Cada tela vai por PR, ou o protótipo tem um ritmo próprio de commit?
