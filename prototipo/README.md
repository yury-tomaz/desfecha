# Protótipo

Protótipo navegável da plataforma em HTML, CSS e JS puros. Vai na frente do `frontend/`: mostra como a plataforma deve ser, com as telas ligadas entre si, antes de alguma ser implementada.

O protótipo é parte do shaping (`docs/PLANS.md`, skill `moldar`): quando um pitch tem interface, a solução dele vira telas aqui, sem acabamento. Um agente revisor, sem a conversa do shaping, revisa as telas antes da aposta, e o humano as vê na aposta. Pitch descartado leva junto as telas que só ele usava.

Para ver: abra `prototipo/index.html` direto no navegador. Não há servidor nem build.

## Regras

- **Sem build e sem dependências.** Nada de `package.json`, gerenciador de pacotes, framework ou script carregado de fora (`<script src="https://...">`, `import` de URL, import map). É uma defesa de cadeia de suprimentos (`docs/SECURITY.md`): o que não é instalado não pode ser comprometido. `scripts/verify.sh` falha se aparecer qualquer um deles.
- **Fonte externa pode entrar** (ex.: Google Fonts, por `<link>`) quando a marca for definida. Script externo, não.
- **O `frontend/` não importa nada daqui.** O protótipo explora e o `frontend/` implementa o que foi escolhido, então os dois podem diferir. Quando uma tela entra no `frontend/`, o pitch aponta para a tela correspondente aqui, na seção "Protótipo". `scripts/verify.sh` falha se um arquivo do `frontend/` referenciar `prototipo/`, inclusive por alias, `url()` de CSS ou symlink.
- **Toda tela nova entra na lista de `index.html`**, para o protótipo continuar navegável a partir da página inicial.

## Marca, fontes e cores

Ainda por definir: são decisões de produto, da fase de produto. Quando forem tomadas:

- A decisão e o motivo vão para um tema em `docs/produto/` (ex.: `docs/produto/marca.md`), listado no índice de `docs/PRODUCT_SENSE.md`.
- Os valores (cores, fontes, espaçamentos) viram variáveis CSS em `prototipo/estilo.css`, que hoje só tem o mínimo para a página ser legível.
