# Como o trabalho anda

Uma adaptação do Shape Up (`docs/referencias/shape-up.md`). Um problema vira **pitch**, o humano aposta ou descarta, e o agente constrói o que foi apostado em **escopos**, descobertos durante o trabalho. Todo o andamento fica no repositório: o que está só no chat não existe.

Vale para tudo, produto e harness. Tarefa de harness tem shaping curto e não tem protótipo.

## Processo

1. **Shaping** (agente e humano, skill `moldar`). O humano traz um problema cru. O agente dá forma junto com ele e escreve o pitch. Decisão de produto que vale além do pitch vai para o tema de `docs/produto/`.
2. **Protótipo** (skill `moldar`). Quando o pitch tem interface, a solução vira telas clicáveis em `prototipo/`, sem acabamento.
3. **Revisão do protótipo** (agente revisor, skill `moldar`). Uma sessão sem a conversa do shaping revisa as telas antes da aposta, e os achados vão para o pitch. O humano só vê o protótipo na aposta.
4. **Aposta** (humano). O humano aposta ou descarta. Aposta vira `Estado: apostado`. Descarte apaga a pasta do pitch, e o git guarda. Não há backlog.
5. **Build** (agente sozinho, skill `executar`). Abre os escopos conforme os descobre, um PR por escopo, empilhados num stack de PRs do GitHub (`gh stack`): cada PR aponta para o escopo de baixo, e o build não espera merge para seguir. TDD, `scripts/verify.sh` e a revisão de PR (`revisar`) valem em todo escopo.

## Apetite e circuit breaker

O apetite é medido pela atenção do humano, não em semanas: cada escopo é um PR que ele vai ler. Não há ciclos fixos nem cooldown.

| Apetite | Escopos | PRs |
|---|---|---|
| `pequeno` | 1 | 1 |
| `grande` | até 4 | até 4 |
| `a definir` | 0 | só no `shaping` |

**Circuit breaker:** se o build precisa de mais escopos do que o apetite permite, o agente para, marca o pitch como `bloqueado` e descreve o que sobrou em "Perguntas em aberto". O humano decide: cortar escopo, voltar ao shaping ou descartar. O apetite nunca cresce sozinho.

## Estados do pitch

A linha `Estado:` logo abaixo do título diz em que ponto o pitch está. O estado substitui pastas de "ativo" e "concluído": sem backlog, quase nunca há mais de um ou dois pitches vivos.

| Estado | Significa | Quem muda |
|---|---|---|
| `shaping` | Ainda tomando forma. Não pode ser construído. | Skill `moldar` |
| `apostado` | O humano apostou. Pronto para o build. | Só o humano aposta, a skill `moldar` grava |
| `em-build` | Uma sessão reservou e está construindo. | Skill `executar`, com commit e push no `main` |
| `bloqueado` | Parou numa pergunta que precisa do humano, ou no circuit breaker. | Skill `executar` |
| `entregue` | Todos os escopos construídos. Fica na pasta como histórico. | Skill `executar`, no PR do último escopo |

**Reserva:** a `executar` troca o pitch para `em-build` com commit e push no `main`. O push é a reserva: uma sessão por pitch.

## Colina

Cada escopo tem uma linha `Colina:` (o *hill chart* do Shape Up):

- `subindo`: ainda descobrindo como fazer.
- `descendo`: já se sabe o que falta, só resta fazer.

Escopo parado em `subindo` é o sinal de risco para o humano. A troca de `subindo` para `descendo` é registrada no log de progresso do escopo.

## Onde fica cada coisa

```
docs/pitches/<AAAA-MM-DD>-<slug>/
  pitch.md
  escopos/
    <escopo>.md
```

Uma pasta por pitch: quem constrói lê uma pasta e tem o contexto inteiro. O nome da pasta é o que vai em `TODO(<pasta-do-pitch>): ...`.

Os exec-plans do começo do harness, do formato anterior, estão em `docs/historico/exec-plans/`.

### pitch.md

```markdown
# <Pitch>

Estado: shaping
Apetite: a definir

## Problema
O que dói, para quem, e por que agora.

## Solução
Os elementos da solução e como se ligam: lugares, o que se aciona em cada um, e para onde leva (breadboard). Grosso, sem acabamento.

## Protótipo
As telas em `prototipo/` que mostram a solução, ou "Sem interface."

## Rabbit holes
Armadilhas já vistas e como a solução as evita.

## No-gos
O que fica de fora de propósito.

## Revisão do protótipo
Achados do agente revisor e o que mudou por causa deles, ou "Sem protótipo."

## Log de decisões
- **D1. <decisão>**: motivo.

## Perguntas em aberto
Só o que precisa de julgamento humano.
```

### escopos/\<escopo\>.md

```markdown
# <Escopo>

Colina: subindo

## Objetivo
O que este escopo entrega, construído e integrado de ponta a ponta.

## Critérios de aceite
- [ ] item verificável, dizendo como é comprovado (teste ou comando)

## Log de progresso
- AAAA-MM-DD: o que foi feito.

## Log de decisões
- **D1. <decisão>**: motivo.

## Perguntas em aberto
```

## Checagem

`scripts/plan-check.sh [pasta-do-pitch ...]` confere a estrutura. Sem argumento, confere todos os pitches de `docs/pitches/`, e o `scripts/verify.sh` roda assim. Ela recusa:

- `pitch.md` sem uma das seções, sem `Estado:` válido, ou sem `Apetite:` válido;
- `Apetite: a definir` fora do `shaping`;
- fora do `shaping`, seção vazia em Problema, Solução, Protótipo, Rabbit holes, No-gos ou Revisão do protótipo;
- `apostado` com perguntas em aberto; `bloqueado` sem nenhuma pergunta em aberto;
- mais escopos do que o apetite permite;
- escopo sem `Colina:` válida, sem uma das seções, ou sem itens em "Critérios de aceite";
- `entregue` sem escopos ou com critério de aceite não marcado.

## Regras

- Construa só o que está no pitch. Os no-gos são no-gos.
- Decisões técnicas dentro do pitch são tomadas por quem constrói e registradas com motivo no log de decisões do escopo.
- O que precisa de julgamento humano vai para "Perguntas em aberto", e o build para naquele ponto.
- O log de progresso do escopo é atualizado durante o trabalho, não só no fim.
