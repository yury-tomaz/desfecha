# Product Sense

Por que o produto existe e o que é "bom" aqui.

## Em uma frase

Plataforma de atendimento em que agentes de IA resolvem os chamados dos clientes de ponta a ponta, e a empresa paga por chamado resolvido, não por atendente.

## Modelo: Services as a Software

Não é um SaaS comum. Vendemos o **serviço executado** (chamado resolvido), não o acesso a uma ferramenta.

- Não cobrar por atendente, assento ou licença.
- A IA não é um custo extra em cima da ferramenta: ela é o produto.
- O valor entregue é medido em chamados resolvidos.

Na dúvida entre um padrão de SaaS tradicional e algo que aproxima o produto de "serviço executado", prefira o segundo.

## Para quem

E-commerces brasileiros de pequeno e médio porte que atendem principalmente pelo WhatsApp. É o nicho inicial.

## Problema

- O volume de atendimento cresce junto com as vendas, e para dar conta é preciso contratar mais atendentes.
- As ferramentas atuais (Zendesk e similares) cobram por atendente, com a IA como custo extra.
- A maior parte dos chamados é repetitiva: onde está meu pedido, troca, reembolso, segunda via.

## Solução

- O agente de IA atende pelo WhatsApp, por e-mail e pelo site.
- O agente **executa a ação**, não só responde: consulta o pedido, gera a troca, faz o reembolso, emite o boleto.
- Quando o caso precisa de julgamento, passa para um humano com o contexto pronto.

## Fluxo do chamado

```
cliente escreve → vira ticket → agente IA entende e age
  → resolvido → pesquisa de satisfação
  → não resolvido → atendente humano assume com o histórico
```

## Implicações

- **"Resolvido" é a unidade de cobrança.** O registro de resolução é auditável e não pode ser alterado depois.
- **A IA move dinheiro real.** Toda ação (reembolso, troca, boleto) precisa de limite por tenant, de aprovação humana acima do limite, de ser idempotente e de ficar registrada com o motivo.
- **Multi-tenant.** Um tenant nunca pode ver dados de outro. É a falha mais grave possível.
- **Dados pessoais (LGPD).** As conversas têm CPF, endereço e dados de pedido.
- **O handoff para humano faz parte do produto,** não é uma falha. O humano precisa receber o contexto completo.

## Perguntas em aberto

- O que conta como "resolvido"? Cliente confirmou? Não houve reabertura em X dias? Chamado passado para humano conta?
- Quais plataformas de e-commerce e meios de pagamento entram primeiro?
- Quais ações a IA pode executar sozinha, e com quais limites padrão?
- Quais as regras de retenção e mascaramento de dados pessoais (LGPD), e o que pode ser enviado ao modelo de IA?
