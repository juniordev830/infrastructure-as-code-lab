# Guia de validação — Infrastructure as Code Lab

## Estado e abrangência

Laboratório Terraform baseado em `terraform_data`, sem provisionamento externo nem gasto em nuvem.

## Fontes para revisão

`terraform/` e arquivos de teste Terraform; `README.md`.

## Comandos de verificação

`terraform fmt -check -recursive`; `terraform -chdir=terraform init -backend=false`; `terraform -chdir=terraform validate`; `terraform -chdir=terraform test`.

Os testes automatizados devem ser revisados junto do código. Caso não tenham sido executados, registrar essa limitação no PR.

## Matriz de regressão

Validar valores de variáveis inválidos, ambientes fora do enum permitido, plano de mudança e atualização sem efeitos colaterais.

## Cenários de proteção orçamentária

1. Execute `terraform -chdir=terraform init -backend=false`.
2. Com `enforce_budget_limit=false`, verifique que estimativas acima do teto geram `over_budget`, sem impedir o plano.
3. Com `enforce_budget_limit=true`, confirme que `estimated_monthly_cost_usd=100` e `monthly_budget_usd=100` permitem o plano.
4. Com proteção ativa, confirme que estimativa `101` para orçamento `100` falha.
5. Com proteção ativa e orçamento `0`, confirme que o plano falha.
6. Rode `terraform -chdir=terraform test -no-color` e registre o resultado da automação.

O limite protege somente a validação do plano neste laboratório. Os números são estimados e manuais; não substituem políticas de custo, IAM nem monitoramento de faturas.

## Cenários de projeção mensal

- Estimativa de 95 USD, orçamento de 100 USD, crescimento de 10% e três meses: conferir valores 95, 104,50 e 114,95.
- Crescimento de 0%: todos os meses repetem a estimativa inicial.
- Crescimento negativo: os valores devem diminuir de forma composta.
- Sem orçamento definido: `exceeds_budget` deve permanecer `null`.
- Rejeitar `forecast_months` igual a zero ou fracionário e crescimento fora do intervalo permitido.

O recurso de previsão é informativo; a proteção opcional do plano considera apenas o custo do primeiro mês.

## Cenários de rateio por serviços

- Serviços `api=60` e `database=40` com total `100`: status `matched`, parcelas de 60% e 40%.
- Serviços totalizando `100` com estimativa `150`: status `underallocated`; a diferença precisa ser `-50`.
- Total alocado acima da estimativa: status `overallocated`.
- Sem serviços: status `not_configured`, mesmo quando a estimativa total é zero.
- Com `enforce_allocation_match=true`, bloquear plano sem serviços ou com soma diferente do total.
- Rejeitar valores negativos, nomes inválidos e mais de 25 serviços; não dividir por zero em rateio zerado.

## Cenários de risco no horizonte

- Valor inicial 95, crescimento mensal 10%, orçamento 100 e horizonte de 3 meses: acumulado `314.45`, pico `114.95`, excesso em meses 2 e 3.
- Valor igual ao orçamento não é excesso.
- Sem orçamento, risco agregado permanece `not_configured`.
- Com crescimento negativo, sinalizar o primeiro mês se ele já ultrapassar o orçamento.
- Um horizonte de apenas um mês deve continuar válido.

## Próximo incremento fundamentado

Manter plano reproduzível sem cloud. Só adicionar provedores de verdade com conta de testes, política de custos e limpeza documentada.

## Critérios de contribuição

- [ ] Alteração atende comportamento verificável.
- [ ] Foi criada evidência de teste ou procedimento reproduzível.
- [ ] Nenhuma credencial ou dado pessoal foi versionado.
- [ ] O PR identifica claramente o que mudou e o que ainda falta.
