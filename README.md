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

### Projeção mensal de custos (sem cloud)

Para simular uma trajetória de gastos, defina a taxa percentual de crescimento mensal e a quantidade de meses (1 a 24):

```bash
terraform -chdir=terraform plan -var="estimated_monthly_cost_usd=95" -var="monthly_budget_usd=100" -var="monthly_growth_rate_percent=10" -var="forecast_months=3"
```

A saída `forecast_summary.monthly_projection` calcula a partir do primeiro mês **95,00 → 104,50 → 114,95 USD**. Cada mês possui o campo `exceeds_budget`; ele fica `null` quando não há orçamento definido. A taxa aceita entre -100% e 100% e os valores são arredondados a centavos.

O bloqueio `enforce_budget_limit`, quando ativado, verifica **somente o custo estimado inicial**. O bloqueio futuro é configurado separadamente com `enforce_forecast_budget_limit`, descrito abaixo. A projeção usa estimativas manuais, não uma previsão de faturas reais.

### Bloqueio opcional de excesso em meses futuros

Para **impedir o plano se qualquer mês projetado ultrapassar o teto**, ative a proteção do horizonte:

```bash
terraform -chdir=terraform plan -var="estimated_monthly_cost_usd=95" -var="monthly_budget_usd=100" -var="monthly_growth_rate_percent=10" -var="forecast_months=3" -var="enforce_forecast_budget_limit=true"
```

Esse exemplo falha, pois os meses 2 e 3 excedem 100 USD. Com `enforce_forecast_budget_limit=false` (padrão), o resultado continua informativo. Quando a proteção está ativa, é obrigatório definir `monthly_budget_usd` maior que zero, e **todos os meses** precisam ficar no limite ou abaixo dele. O campo `forecast_risk_summary.enforcement_enabled` informa se a proteção está ligada.

As proteções são independentes: `enforce_budget_limit` verifica só o mês inicial e `enforce_forecast_budget_limit` verifica o horizonte inteiro. Nenhuma delas controla despesas reais em provedores de nuvem.

### Orçamento acumulado para todo o período

Além dos limites de cada mês, use `forecast_total_budget_usd` para definir um **teto total** para os meses projetados. A saída `forecast_total_budget_summary` compara esse teto ao custo somado e apresenta o saldo e o percentual utilizado.

```bash
terraform -chdir=terraform plan -var="estimated_monthly_cost_usd=95" -var="monthly_growth_rate_percent=10" -var="forecast_months=3" -var="forecast_total_budget_usd=300"
```

No exemplo, a projeção acumula **314,45 USD** em três meses, acima do limite de 300 USD. Por padrão, isso gera apenas um aviso no resultado. Para impedir o plano:

```bash
terraform -chdir=terraform plan -var="estimated_monthly_cost_usd=95" -var="monthly_growth_rate_percent=10" -var="forecast_months=3" -var="forecast_total_budget_usd=300" -var="enforce_forecast_total_budget=true"
```

O valor `0` desativa a comparação total, mas **não é permitido** quando `enforce_forecast_total_budget=true`. Um custo exatamente igual ao teto é aceito. Esse controle é independente das opções que validam cada mês e utiliza somente estimativas manuais, não gastos reais.

### Alertas antecipados de orçamento

A variável `budget_warning_threshold_percent` define em qual percentual do teto mensal o sistema começa a alertar (padrão: **80%**, intervalo: 0 a 100). O controle é **informativo** e não impede o plano:

```bash
terraform -chdir=terraform plan -var="estimated_monthly_cost_usd=95" -var="monthly_budget_usd=100" -var="monthly_growth_rate_percent=10" -var="forecast_months=3" -var="budget_warning_threshold_percent=80"
```

O resultado `forecast_warning_summary` informa os meses próximos do limite e a condição geral `healthy`, `warning`, `over_budget` ou `not_configured`. No exemplo, o mês **1** recebe aviso de aproximação e os meses **2 e 3** ultrapassam o teto. O status geral é `over_budget`, sem confundir aviso com excesso.

Quando não há orçamento, não são gerados alertas. Uma estimativa exatamente igual ao teto é um aviso, não um excesso. Os avisos são calculados exclusivamente sobre estimativas fornecidas manualmente.

### Rateio por serviço e conciliação offline

Use `service_costs_usd` para distribuir uma estimativa mensal por até 25 serviços e verificar se a soma bate com `estimated_monthly_cost_usd`. As chaves dos serviços devem conter letras minúsculas, números ou hifens.

Em um arquivo `terraform/terraform.tfvars` local (ignorado pelo Git):

```hcl
estimated_monthly_cost_usd = 100
monthly_budget_usd         = 120

service_costs_usd = {
  api      = 60
  database = 40
}

# Opcional: impede o plano se a soma não corresponder ao total.
enforce_allocation_match = true
```

O `allocation_summary` apresenta o total alocado, diferença para a estimativa, percentual por serviço e status `matched`, `underallocated`, `overallocated` ou `not_configured`. Quando `enforce_allocation_match=false` (padrão), a conciliação é informativa. Se ativada, exige ao menos um serviço e correspondência até o centavo.

Esses valores são inseridos manualmente, não representam dados reais de faturamento e não criam recursos de nuvem.

### Resumo de riscos da projeção

O `forecast_risk_summary` resume os meses simulados: custo acumulado, maior estimativa mensal, meses que ultrapassariam o teto e primeiro mês com excesso.

Por exemplo, com valor inicial de 95 USD, crescimento de 10%, orçamento de 100 USD e três meses, a simulação retorna **314,45 USD acumulados**, maior mês de **114,95 USD** e excesso começando no mês **2**. Quando o orçamento é zero, o status fica `not_configured` e nenhum mês é marcado como excesso.

Esses cálculos são orientativos; não recuperam faturas nem substituem um monitoramento real de custos.

## Segurança e limitações

MVP não provisiona máquinas, redes nem recursos cloud. Não versionar arquivos `.tfstate` e credenciais. Use `terraform plan` antes de qualquer `apply` em projetos reais.

## Evolução planejada

Adicionar exemplos isolados Docker e módulos de infraestrutura cloud com simulação de custos e limites explícitos.

---
Projeto de Engenharia de Software mantido na conta [juniordev830](https://github.com/juniordev830).

## Guia para contribuir

Veja o [roteiro de testes e manutenção](docs/GUIA_DE_VALIDACAO.md) para validar mudanças com comandos e cenários específicos deste projeto.
