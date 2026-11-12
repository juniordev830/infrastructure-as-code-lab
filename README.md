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
terraform -chdir=terraform init -backend=false
terraform -chdir=terraform validate
terraform -chdir=terraform test
```

Com o Terraform 1.9.8, os testes confirmam que o plano preserva os metadados e rejeita ambientes desconhecidos. O GitHub Actions executa as mesmas verificações em pushes e pull requests.

## Simulacao de orcamento (sem cloud)

O laboratório agora oferece uma comparação **informativa** entre estimativa mensal e teto definido manualmente, sem acesso a faturas reais e sem provisionar recursos. `monthly_budget_usd = 0` desativa a comparação.

```bash
terraform -chdir=terraform plan -var="estimated_monthly_cost_usd=80" -var="monthly_budget_usd=100"
```

O `budget_summary` mostra o status `within_budget`, `over_budget` ou `not_configured`, a diferença entre orçamento e custo previsto e `utilization_percent` (percentual utilizado). Quando o orçamento é zero, `remaining_usd` e `utilization_percent` são `null` para evitar divisão por zero. Valores acima do teto **não bloqueiam** o plano: a saída é apenas um aviso analítico. Os testes em `terraform/tests/budget.tftest.hcl` cobrem limites e validações.

### Bloqueio opcional no plano

Por padrão, o resultado continua **informativo**: o plano é permitido mesmo quando a estimativa supera o orçamento. Para ativar uma proteção **local e explícita**, use `enforce_budget_limit=true`:

```bash
terraform -chdir=terraform plan -var="estimated_monthly_cost_usd=80" -var="monthly_budget_usd=100" -var="enforce_budget_limit=true"
```

Quando a proteção está ativada, `terraform plan` falha se o teto estiver ausente ou for zero, ou se a estimativa ultrapassar o teto. A igualdade com o limite é aceita. A propriedade `budget_summary.enforcement_enabled` informa o modo configurado.

Para conferir a rejeição, altere a estimativa de `80` para `120` no comando acima. Não é necessário executar `apply`. Os testes automatizados cobrem o modo informativo, a igualdade, valores abaixo/acima do teto e orçamento não configurado.

> **Importante:** o controle compara números fornecidos manualmente; não consulta gastos reais, não impede cobranças externas e não provisiona infraestrutura.

## Segurança e limitações

MVP não provisiona máquinas, redes nem recursos cloud. Não versionar arquivos `.tfstate` e credenciais. Use `terraform plan` antes de qualquer `apply` em projetos reais.

## Evolução planejada

Adicionar exemplos isolados Docker e módulos de infraestrutura cloud com simulação de custos e limites explícitos.

---
Projeto de Engenharia de Software mantido na conta [juniordev830](https://github.com/juniordev830).

## Guia para contribuir

Veja o [roteiro de testes e manutenção](docs/GUIA_DE_VALIDACAO.md) para validar mudanças com comandos e cenários específicos deste projeto.
