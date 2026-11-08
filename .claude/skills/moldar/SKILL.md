---
name: moldar
description: Dá forma a um problema junto com o humano até virar um pitch (com protótipo, quando tem interface), roda a revisão do protótipo e grava a aposta ou o descarte. Use quando o humano trouxer um problema novo, quiser continuar um pitch em shaping, ou decidir voltar ao shaping ou descartar um pitch bloqueado.
disable-model-invocation: true
---

# Moldar um pitch

Você trabalha **com o humano**. O objetivo é um pitch que uma sessão sem memória desta conversa consiga construir sem perguntar nada. Você não escreve código de produção nesta skill: escreve o pitch e, se houver interface, as telas do protótipo.

Leia antes: `AGENTS.md`, `docs/PLANS.md`, `docs/PRODUCT_SENSE.md` e, pelo índice dele, o tema de `docs/produto/` em que o problema toca. Para o porquê do processo: `docs/referencias/shape-up.md`.

A conversa vira o pitch, não fica no chat. Cada resposta do humano muda o pitch na hora.

## Entrada

- Com o caminho de um pitch em `shaping`: continue esse pitch.
- Com o caminho de um pitch `bloqueado`: siga a seção 5.
- Sem caminho: pergunte qual é o problema e crie `docs/pitches/<AAAA-MM-DD>-<slug>/pitch.md` no formato de `docs/PLANS.md`, com `Estado: shaping` e `Apetite: a definir`.

## 1. Shaping

Leve o pitch a ser *rough*, *solved* e *bounded*:

1. **Problema.** O que dói, para quem, e por que agora. Um caso concreto vale mais que uma descrição geral. Se o problema não está claro, não passe daqui.
2. **Apetite.** Quanto da atenção do humano o problema merece: `pequeno` (1 escopo, 1 PR) ou `grande` (até 4). O apetite vem antes da solução: a solução cabe no apetite, não o contrário.
3. **Solução.** Os elementos principais e como se ligam, em breadboard: lugares, o que se aciona em cada um e para onde leva. Grosso, sem detalhe de tela: os detalhes são de quem constrói.
4. **Rabbit holes.** Procure o que pode afundar o build (caso de borda, integração, dado que não existe, decisão técnica difícil) e resolva agora, no pitch.
5. **No-gos.** O que fica de fora de propósito, para fechar as portas óbvias de aumento de escopo.

Revise antes de cada pergunta:

- O pitch conflita com `docs/PRODUCT_SENSE.md`, com o tema de `docs/produto/` ou com outro pitch vivo em `docs/pitches/`?
- O pitch toma uma decisão de produto que vale além dele? Se sim, a decisão vai para o tema certo de `docs/produto/` (em "Decisões", com data e motivo, e o "Estado atual" atualizado), e o pitch aponta para o tema. Se nenhum tema cabe, crie um e o liste no índice de `docs/PRODUCT_SENSE.md`.
- A solução cabe no apetite? Se não cabe, corte a solução ou proponha dividir em dois pitches. O apetite não cresce para caber a solução.

Leve ao humano **uma pergunta por vez**, curta, com a sua recomendação. Decisão técnica que quem constrói pode tomar sozinho não vira pergunta. Decisão tomada no shaping vai para o "Log de decisões" do pitch, com o motivo.

Tarefa de harness (sem interface) tem shaping curto: problema, apetite, solução, rabbit holes, no-gos. "Protótipo" fica "Sem interface." e "Revisão do protótipo", "Sem protótipo."

## 2. Protótipo

Só quando o pitch tem interface. Siga `prototipo/README.md`.

1. O breadboard vira telas clicáveis em `prototipo/`, sem acabamento: só o necessário para o humano entender a solução navegando.
2. Toda tela nova entra na lista de `index.html`.
3. O primeiro pitch com telas traz junto a checagem de tela sem link a partir do `index.html` (sugestão da revisão do PR #4): um script em `scripts/`, com casos num `.test.sh`, rodado pelo `scripts/verify.sh`.
4. "Protótipo" no pitch lista as telas, com o caminho de cada uma.

## 3. Revisão do protótipo

Só quando há protótipo. A revisão é feita por uma sessão **sem a conversa do shaping**: lance um subagente novo (não um fork) com o caminho do pitch e a instrução de seguir esta seção, de "Para o revisor" em diante. O humano não revisa: a atenção dele fica na aposta.

### Para o revisor

Você não participou do shaping. O pitch e as telas são tudo o que existe.

1. Leia o pitch, `docs/PRODUCT_SENSE.md` e o tema de `docs/produto/` que ele cita.
2. Tire screenshots de cada tela com o Chrome headless, em desktop e em celular:

   ```bash
   chrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"   # no Linux: google-chrome
   "$chrome" --headless --disable-gpu --hide-scrollbars --window-size=1280,800 --screenshot=<tela>-desktop.png "file://$PWD/prototipo/<tela>.html"
   "$chrome" --headless --disable-gpu --hide-scrollbars --window-size=390,844 --screenshot=<tela>-celular.png "file://$PWD/prototipo/<tela>.html"
   ```

   Os screenshots ficam fora do repositório (na pasta temporária da sessão).
3. Confira, tela a tela:
   - **Heurísticas de Nielsen:** visibilidade do estado do sistema; correspondência com o mundo real; controle e liberdade do usuário; consistência e padrões; prevenção de erros; reconhecer em vez de lembrar; flexibilidade e eficiência; design estético e minimalista; ajudar a reconhecer, diagnosticar e corrigir erros; ajuda e documentação.
   - **Acessibilidade básica:** contraste do texto; todo campo e botão com rótulo; foco visível e alcançável pelo teclado; ordem de leitura que faz sentido no HTML.
   - **`docs/PRODUCT_SENSE.md`:** handoff para humano chega com o contexto; ação que move dinheiro mostra o limite e pede aprovação.
   - **O pitch:** as telas mostram a solução do pitch, e nada dos no-gos.
4. Escreva os achados em "Revisão do protótipo" no pitch, um por linha, com a tela e o que está errado. Sem achado, escreva "Nenhum achado." e o que foi conferido. Não altere as telas.

### Depois da revisão

De volta ao shaping: corrija as telas ou o pitch para cada achado, e registre ao lado do achado o que mudou, ou por que ficou como está. Achado que pede decisão de produto vira pergunta para o humano.

## 4. Aposta

Só o humano aposta. Quando o pitch estiver pronto:

1. Confira: nenhuma seção vazia, `Apetite` definido, nenhuma pergunta em aberto, e a revisão do protótipo feita (se houver protótipo).
2. Mostre ao humano o pitch e, se houver, como abrir o protótipo (`prototipo/index.html`). Pergunte: aposta ou descarta?
3. **Aposta:** troque para `Estado: apostado` e registre no "Log de decisões": `AAAA-MM-DD: apostado pelo humano.` Rode `scripts/plan-check.sh <pasta-do-pitch>`: se falhar, volte para `shaping` e corrija o que ele aponta. Commit no `main` (`pitch: aposta <slug>`) e push.
4. **Descarte:** apague a pasta do pitch e as telas do protótipo que só ele usa, com `git rm -r`. Commit no `main` (`pitch: descarta <slug>`, com o motivo do humano na mensagem) e push. O git guarda; não há backlog.
5. Sem resposta, o pitch continua `shaping`.

## 5. Pitch bloqueado

O build parou numa pergunta (seção 7 da `executar`), e o humano decide. Responder ou cortar escopo continua o build: indique `/executar <pasta-do-pitch>` e pare. Aqui ficam voltar ao shaping e descartar. Sem a decisão dita na sessão, pergunte.

Tudo acontece no `main`, atualizado (`git pull --ff-only`). O que já foi mergeado do stack está nele; o resto está só nos branches `pitch/<slug>/*`.

1. **Encerre o stack.** Liste os PRs do pitch:

   ```bash
   gh pr list --state all --limit 100 --json number,state,headRefName \
     --jq '.[] | select(.headRefName | startswith("pitch/<slug>/"))'
   ```

   Feche cada PR aberto com `gh pr close <n> --delete-branch`. Remova a worktree (`git worktree remove .worktrees/<slug>`) e os branches locais do pitch, se existirem nesta máquina.
2. **Registre a decisão.** Tire a pergunta de "Perguntas em aberto" (do pitch, ou do escopo onde ela estava) e registre no "Log de decisões" do pitch: a pergunta, a decisão do humano com o motivo, a data e os PRs que já foram mergeados.
3. **Voltar ao shaping:** troque para `Estado: shaping`, no mesmo commit. Os escopos mergeados ficam em `escopos/` e contam no apetite do novo shaping. Commit (`pitch: volta ao shaping <slug>`), push, e continue pela seção 1.
4. **Descartar:**
   - Sem escopo mergeado: apague a pasta do pitch, como no descarte da seção 4.
   - Com escopo mergeado: o pitch fica como contexto do código que já está no `main`, e dos `TODO(<pasta-do-pitch>)`. Troque para `Estado: entregue` e registre em "No-gos" o que não foi construído, com o motivo do humano. `scripts/plan-check.sh` aceita, porque todo escopo mergeado foi concluído com os critérios marcados. Reverter o que foi mergeado é decisão do humano, num pitch próprio.

   Commit (`pitch: descarta <slug>`, com o motivo do humano na mensagem) e push.

## Commits

O shaping acontece no `main`: commit (`pitch: molda <slug>`) e push a cada avanço que valha guardar, para o pitch não ficar só nesta sessão. O push roda o `scripts/verify.sh`, que confere a estrutura do pitch.

## Não faça

- Não escreva código de produção nem crie worktree.
- Não marque `apostado` sem a resposta explícita do humano.
- Não faça a revisão do protótipo na mesma sessão do shaping.
- Não encha o pitch com o que dá para descobrir lendo o código.
- Não crie escopos: eles são descobertos no build.
