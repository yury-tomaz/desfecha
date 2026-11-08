# Harness engineering para quem usa agentes de código

"Harness engineering for coding agent users", de Birgitta Böckeler (Thoughtworks), em martinfowler.com, 02/04/2026: https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html

## O que o artigo diz

- **Harness** é tudo num agente que não é o modelo ("Agent = Model + Harness"). Parte vem pronta com a ferramenta; o resto é construído por quem usa. O objetivo é o agente acertar na primeira vez e corrigir o que errar antes de chegar à revisão humana.
- **Guides** (feedforward) orientam o agente antes de ele agir. **Sensors** (feedback) observam depois e permitem a autocorreção. Só sensores dão um agente que repete erros; só guias dão regras que ninguém confere.
- **Computacional ou inferencial.** Controles computacionais são determinísticos e rápidos: testes, linters, checagem de tipos, testes estruturais. Inferenciais usam um modelo: revisão por IA, "LLM as judge". São mais lentos, caros e não determinísticos.
- **O papel do humano** é dirigir melhorando o harness: quando um problema acontece mais de uma vez, os guias e sensores mudam para que ele fique menos provável ou impossível. Um bom harness não tira o humano: leva a atenção dele para onde ela mais importa.

## O que o harness usa

- Guias: `AGENTS.md`, `docs/` e as skills (`moldar`, `executar`, `revisar`).
- Sensores computacionais: `scripts/verify.sh` (testes, lint, formatação, segredos, dependências, estrutura de pitch e escopo).
- Sensores inferenciais: a revisão de PR (`revisar`) e a revisão do protótipo, feitas por uma sessão sem a conversa de quem escreveu.
- A atenção do humano vai para a decisão (shaping e aposta), não para a revisão. Problema que se repete vira guia ou sensor novo.
