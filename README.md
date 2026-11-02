# Infrastructure as Code Lab

Laboratório Terraform **sem provedor de nuvem e sem cobrança**: valida variáveis e mantém metadados de um ambiente usando `terraform_data`.

## Estado

**MVP funcional / projeto inicial de portfólio.** Implementa o núcleo descrito abaixo, mas não é produto pronto para produção.

## Como executar

```bash
terraform -chdir=terraform init
terraform -chdir=terraform validate
terraform -chdir=terraform plan
```

## Testes

```bash
terraform fmt -check -recursive
terraform -chdir=terraform validate
```

O GitHub Actions executa os testes automaticamente em pushes e pull requests.

## Segurança e limitações

MVP não provisiona máquinas, redes nem recursos cloud. Não versionar arquivos `.tfstate` e credenciais. \nUse `terraform plan` antes de qualquer `apply` em projetos reais.

## Evolução planejada

Adicionar exemplos isolados Docker e módulos de infraestrutura cloud com simulação de custos e limites explícitos.

---
Projeto de Engenharia de Software mantido na conta [juniordev830](https://github.com/juniordev830).
