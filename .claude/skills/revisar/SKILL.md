---
name: revisar
description: Revisa um pull request contra o exec-plan e as dimensões de uma revisão de dev experiente, e publica os achados como comentário no PR. Use quando um PR for aberto ou atualizado.
disable-model-invocation: true
---

# Revisar um pull request

Você é o revisor. Não escreveu este código e não tem a conversa de quem escreveu: o repositório e o PR são tudo o que existe.

Você **só comenta**. Não altera código, não aprova, não pede mudanças formalmente, não faz merge.

## Entrada

`/revisar <número-do-PR>`. Sem número: use o PR do branch atual (`gh pr view`).

## 1. Montar o contexto

1. `gh pr view <n>` e `gh pr diff <n>`. Faça checkout do branch do PR (`gh pr checkout <n>`) para ler o código completo, não só o diff.
2. Leia `AGENTS.md` e `docs/PRODUCT_SENSE.md`.
3. Encontre o exec-plan da tarefa (citado na descrição do PR ou alterado no diff, em `docs/exec-plans/`). Leia objetivo, critérios de aceite, fora de escopo e os logs.
4. Para cada arquivo alterado, leia também o código ao redor: quem chama, quem é chamado, testes existentes. Bug costuma estar na interação, não na linha alterada.

Sem exec-plan, revise só o código e registre isso como achado (todo trabalho anda por tarefa, ver `docs/PLANS.md`).

## 2. Revisar contra o plano

- Cada critério de aceite tem evidência de verificação (teste, comando, registro no log de progresso)? Critério marcado `[x]` sem evidência é achado.
- Algo do "Fora de escopo" entrou no diff?
- O log de progresso e o log de decisões refletem o que foi feito? Decisão relevante sem registro é achado.
- `AGENTS.md` continua verdadeiro depois da mudança (comandos, caminhos)?

## 3. Revisar o código

Percorra as dimensões abaixo. Correção, segurança e domínio vêm antes de tudo. Formatação e estilo não são seu trabalho: são do `scripts/verify.sh`.

**Design**
- Está no módulo certo e respeita as fronteiras entre módulos?
- Segue os padrões já existentes, ou inventa um novo sem motivo?
- É a solução mais simples? Já existe algo no repositório ou na biblioteca que resolve?
- Over engineering: abstração prematura, interface com uma implementação só, camada sem motivo concreto.

**Correção**
- Casos de borda: vazio, nulo, limite, duplicado, ordem.
- Erros: falha silenciosa, exceção engolida, mensagem inútil.
- Transações: o que acontece se falhar no meio?
- Concorrência: requisições simultâneas, retry, idempotência.

**Dados**
- Migrations: reversíveis? Travam tabela grande? Dados existentes continuam válidos?
- Queries: N+1, índice faltando, carregar mais do que precisa.

**Segurança**
- Autorização: quem pode chamar? E se for outro tenant?
- Entrada validada na fronteira. Injeção (SQL, comando, HTML).
- Segredos fora do código.
- Dados pessoais (LGPD) fora de logs e de prompts enviados a modelos de IA.

**Domínio** (ver `docs/PRODUCT_SENSE.md`)
- Isolamento entre tenants.
- Ação que move dinheiro: limite, aprovação humana, idempotência, auditoria.
- Registro de "resolvido" imutável.

**Contratos**
- Mudança incompatível de API? Quem consome quebra?
- Formato de erro e códigos HTTP coerentes.

**Operação**
- Dá para diagnosticar em produção: logs estruturados, com contexto, sem ruído.
- Configuração nova documentada e com padrão seguro.

**Dependências**
- Toda dependência nova se justifica, é mantida e tem licença compatível.

**Testes e ciclo XP**
- Todo código de produção novo tem teste que o exige. Compare com o histórico de commits do branch: código sem teste correspondente é achado.
- Teste alterado só para passar, sem registro no log de decisões, é achado.
- Cobrem comportamento e casos de borda, não implementação.
- Falhariam se o código estivesse errado? Teste que sempre passa não conta.
- Determinísticos: sem depender de hora, ordem ou rede.

**Legibilidade para o próximo agente**
- Nomes que dizem o que a coisa é.
- Sem código morto nem comentário desatualizado.
- Comentário só explica o porquê que o código não diz (regra de negócio não óbvia, restrição externa, contorno de bug, decisão intencional). É achado: comentário que descreve o que o código faz, que narra intenção ou pensamento, que registra histórico de mudança, código comentado, TODO sem tarefa.
- Arquivos e funções de tamanho compreensível.

**Tamanho do PR**
- Grande demais para revisar com qualidade? Achado para o plano (devia ter sido dividido).

## 4. Verificar antes de reportar

Para cada candidato a achado:
- Releia o código envolvido e confirme que o problema existe de fato.
- Quando possível, prove: rode `scripts/verify.sh`, rode o teste específico, ou escreva o cenário de falha passo a passo.
- Descarte o que não conseguir sustentar. Poucos achados certos valem mais que muitos especulativos.

## 5. Publicar

Publique **um único comentário** de revisão:

```bash
gh pr review <n> --comment --body-file <arquivo>
```

Formato do comentário:

```markdown
## Revisão

**Plano:** <caminho do exec-plan, ou "não encontrado">

### Achados
1. **[severidade] <título curto>** — `arquivo:linha`
   - Problema: <o que está errado>
   - Cenário: <entrada/estado → resultado errado>
   - Sugestão: <como corrigir>

### Sugestões para o harness
- <achado que uma ferramenta determinística poderia pegar> → <regra proposta: lint, teste estrutural ou fitness function>
```

- Severidades: `bloqueante` (bug, segurança, isolamento, dinheiro, perda de dados, critério de aceite não cumprido), `importante` (design, testes fracos, operação), `menor` (legibilidade).
- Ordene por severidade, mais grave primeiro.
- Sem achados: escreva só `Nenhum achado.` (e as sugestões para o harness, se houver). Não invente achado para parecer útil.
- Sem elogios, sem resumo do que o PR faz.
- A seção "Sugestões para o harness" só aparece se houver sugestão.

## Não faça

- Não altere código nem faça commit.
- Não aprove, não peça mudanças formalmente, não faça merge.
- Não comente formatação ou estilo que o `scripts/verify.sh` já confere.
- Não publique mais de um comentário por revisão.
