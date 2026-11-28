# Engenharia reversa e estudo — Infrastructure as Code Lab

## Objetivo e fluxo

Modelagem Terraform de metadados, orçamento e previsões. terraform/variables.tf valida entradas. main.tf mantém a base local e os módulos de orçamento, previsão e risco calculam saídas relacionadas.

**Tecnologias identificadas** · Terraform.

**Revisão de referência** · `bcb8d7ceea34`.

## Mapa do código

| Caminho | Papel de leitura | Símbolos selecionados |
| --- | --- | --- |
| [terraform/alerts.tf](../terraform/alerts.tf) | Declarações e expressões Terraform | `forecast_warning_summary` |
| [terraform/allocation.tf](../terraform/allocation.tf) | Declarações e expressões Terraform | `allocation_summary` |
| [terraform/budget.tf](../terraform/budget.tf) | Declarações e expressões Terraform | `budget_summary` |
| [terraform/forecast.tf](../terraform/forecast.tf) | Declarações e expressões Terraform | `forecast_summary` |
| [terraform/horizon_budget.tf](../terraform/horizon_budget.tf) | Declarações e expressões Terraform | `forecast_total_budget_summary` |
| [terraform/main.tf](../terraform/main.tf) | Declarações e expressões Terraform | `terraform_data` |
| [terraform/outputs.tf](../terraform/outputs.tf) | Declarações e expressões Terraform | `environment_summary` |
| [terraform/risk.tf](../terraform/risk.tf) | Declarações e expressões Terraform | `forecast_risk_summary` |
| [terraform/variables.tf](../terraform/variables.tf) | Declarações e expressões Terraform | — |

## Configuração e referências

Referências existentes: [docs/GUIA_DE_VALIDACAO.md](GUIA_DE_VALIDACAO.md).

## Roteiro de estudo e desenvolvimento

1. Comece pelo fluxo descrito acima e localize seus pontos de entrada no mapa. Acompanhe uma entrada válida até a transformação ou a resposta.
2. Abra um teste relacionado ao fluxo e descreva qual regra ele protege. Compare o tratamento esperado para entradas válidas, inválidas e nos limites.
3. Ao adicionar uma regra, determine qual módulo controla o dado e cubra o caso nesse nível. Em seguida, confira o efeito no comando, na API ou na interface de entrada.

**Pergunta de entrevista**

O que a leitura de terraform plan permite verificar antes de mudar o estado local?

## Testes versionados

Os comandos e versões de runtime usados no CI ficam em [.github/workflows/ci.yml](../.github/workflows/ci.yml).

[Voltar ao README](../README.md).
