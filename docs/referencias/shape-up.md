# Shape Up

*Shape Up: Stop Running in Circles and Ship Work that Matters*, de Ryan Singer (Basecamp): https://basecamp.com/shapeup

## O que o livro diz

- **Shaping** (cap. 2, https://basecamp.com/shapeup/1.1-chapter-02): dar forma a uma ideia antes de apostar nela, no nível certo de abstração. O trabalho moldado é *rough* (deixa os detalhes para quem constrói), *solved* (as peças principais estão definidas e se ligam, e os riscos conhecidos foram tirados) e *bounded* (tem apetite e diz o que não fazer). O shaping corre numa trilha separada do build.
- **Apetite** (cap. 3, https://basecamp.com/shapeup/1.2-chapter-03): quanto tempo se quer gastar, o contrário de uma estimativa. A estimativa parte do desenho e chega a um número; o apetite parte de um número e chega a um desenho. Tempo fixo, escopo variável. Dois tamanhos: *small batch* (1 a 2 semanas) e *big batch* (o ciclo de 6 semanas).
- **Breadboard e fat marker sketch** (cap. 4, https://basecamp.com/shapeup/1.3-chapter-04): o breadboard é um esboço sem estilo, feito de lugares, *affordances* (o que o usuário aciona) e as ligações entre eles. O fat marker sketch é um desenho grosso, em que não cabe detalhe.
- **Pitch** (cap. 6, https://basecamp.com/shapeup/1.5-chapter-06): o documento que leva o trabalho moldado para a aposta. Cinco partes: problema, apetite, solução, *rabbit holes* (armadilhas apontadas de antemão) e *no-gos* (o que fica explicitamente de fora).
- **Sem backlog e betting table** (caps. 7 e 8, https://basecamp.com/shapeup/2.1-chapter-07 e https://basecamp.com/shapeup/2.2-chapter-08): não há fila de ideias. A cada ciclo, quem decide escolhe entre poucos pitches recentes. O que não é escolhido não é guardado: o que importa volta.
- **Circuit breaker** (cap. 8): projeto que não termina no ciclo é cancelado por padrão, sem extensão. O apetite não cresce, e o problema volta para o shaping.
- **Escopos** (cap. 12, https://basecamp.com/shapeup/3.3-chapter-12): partes do projeto que se constroem, integram e terminam de forma independente. São descobertos durante o trabalho, não definidos antes.
- **Hill chart** (cap. 13, https://basecamp.com/shapeup/3.4-chapter-13): cada escopo está subindo a colina (ainda descobrindo como fazer) ou descendo (as incógnitas acabaram, falta executar). Sem percentual nem estimativa.

## O que o harness usa

- Shaping com o humano, escrito como pitch com as cinco partes: skill `moldar`, formato em `docs/PLANS.md`.
- Breadboard como solução do pitch, e protótipo em `prototipo/` quando há interface.
- Aposta do humano, sem backlog: pitch descartado é apagado, e o git guarda.
- Apetite fixo e escopo variável, com circuit breaker: o build para quando precisa de mais escopos do que o apetite permite.
- Escopos descobertos no build, cada um com a sua colina (`subindo` ou `descendo`).

## O que o harness muda

- O apetite é medido pela atenção do humano, não em semanas: um agente faz em horas o que um time faz em semanas. Por isso o tamanho é contado em escopos (pequeno: 1; grande: até 4).
- Não há ciclos fixos nem *cool-down*. Um pitch apostado começa quando uma sessão o reserva.
