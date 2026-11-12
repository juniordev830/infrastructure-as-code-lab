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

## Próximo incremento fundamentado

Manter plano reproduzível sem cloud. Só adicionar provedores de verdade com conta de testes, política de custos e limpeza documentada.

## Critérios de contribuição

- [ ] Alteração atende comportamento verificável.
- [ ] Foi criada evidência de teste ou procedimento reproduzível.
- [ ] Nenhuma credencial ou dado pessoal foi versionado.
- [ ] O PR identifica claramente o que mudou e o que ainda falta.
