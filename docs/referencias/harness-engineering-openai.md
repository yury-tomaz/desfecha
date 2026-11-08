# Harness engineering (OpenAI)

"Harness engineering: leveraging Codex in an agent-first world", de Ryan Lopopolo (time do Codex, OpenAI), fevereiro de 2026: https://openai.com/index/harness-engineering/

A página recusa leitura automática (HTTP 403). O resumo abaixo vem de fontes secundárias, não do texto original:

- a resenha em https://ai-playbooks.pages.dev/reviews/harness-engineering-leveraging-codex-in-an-agent-first-world;
- o artigo da Birgitta Böckeler ([harness-engineering-fowler.md](harness-engineering-fowler.md)), que descreve o post;
- a árvore de pastas do post, citada em resultados de busca.

Antes de apoiar uma decisão num detalhe que só aparece aqui, confira no original.

## O que o post descreve

- Um time pequeno entregou um produto inteiro sem código escrito por humano: os agentes escrevem, os humanos dirigem.
- **`AGENTS.md` como mapa:** um arquivo curto (cerca de 100 linhas), que funciona como índice e aponta para uma árvore `docs/` estruturada, em vez de ser um manual.
- **`docs/` como fonte de verdade:** arquitetura, documentos de design, especificações de produto, referências e políticas de qualidade e segurança ficam no repositório. O que o agente não acha no repositório, para ele, não existe.
- **Planos de execução versionados:** os planos são artefatos de primeira classe, guardados no repositório, numa pasta de planos dentro de `docs/`, separados em ativos e concluídos, ao lado de um registro de dívida técnica.
- **Regras conferidas por máquina:** linters próprios e testes estruturais impõem as invariantes de arquitetura. A mensagem de erro do lint traz a correção, para o agente seguir.
- **Coleta de lixo recorrente:** agentes em segundo plano procuram desvio de padrão e documentação desatualizada, e abrem PRs pequenos de correção. Feedback humano que se repete deixa de ser documento e vira regra em código.

## O que o harness usa

- `AGENTS.md` como mapa, sem repetir o que o código diz.
- `docs/` como fonte de verdade: "O que não está no repositório não existe" (regra do `AGENTS.md`).
- O registro do trabalho no repositório, com log de progresso e log de decisões. Hoje em pitches e escopos (`docs/PLANS.md`); os exec-plans do começo do harness estão em `docs/historico/exec-plans/`.
- Checagens em `scripts/verify.sh` com mensagem que diz como corrigir.
- Coleta de lixo recorrente: ainda não existe; é sugestão de próxima tarefa.
