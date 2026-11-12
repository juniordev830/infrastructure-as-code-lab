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

## Próximo incremento fundamentado

Manter plano reproduzível sem cloud. Só adicionar provedores de verdade com conta de testes, política de custos e limpeza documentada.

## Critérios de contribuição

- [ ] Alteração atende comportamento verificável.
- [ ] Foi criada evidência de teste ou procedimento reproduzível.
- [ ] Nenhuma credencial ou dado pessoal foi versionado.
- [ ] O PR identifica claramente o que mudou e o que ainda falta.
