# Sistema de Análise de Absenteísmo

![Badge em Desenvolvimento](https://img.shields.io/badge/Status-Em%20Desenvolvimento-green)
![Badge Versão](https://img.shields.io/badge/Versão-1.0.0-blue)

## 📋 Descrição do Projeto

Sistema desenvolvido para análise e monitoramento de faltas de funcionários, integrando dados de diferentes fontes para gerar insights sobre absenteísmo corporativo. O projeto inclui análises em SQL, implementação em Power BI e métricas personalizadas para gestão eficiente de recursos humanos.

## 🎯 Funcionalidades Principais

- Tracking de faltas por funcionário
- Análise de custos relacionados ao absenteísmo
- Dashboard interativo em Power BI
- Sistema de alertas para faltas frequentes
- Relatórios automatizados
- Análise temporal de tendências

## 🔧 Tecnologias Utilizadas

- SQL Server
- Power BI
- DAX
- Git/GitHub



## 📈 Métricas Principais

1. **Métricas Básicas**
   - Taxa de absenteísmo
   - Média de faltas por funcionário
   - Custo médio por falta
   - Distribuição dos motivos

2. **Análise Financeira**
   - Custo total das faltas
   - Impacto financeiro por tipo
   - Relação salário/frequência

3. **Indicadores de Alerta**
   - Funcionários com faltas frequentes
   - Departamentos críticos
   - Custos excedentes

## 💻 Dashboard Power BI

### Páginas Principais

1. **Overview**
   - KPIs gerais
   - Tendências mensais
   - Distribuição de motivos

2. **Análise de Custos**
   - Custo total e médio
   - Top 10 impactos financeiros
   - Análise por departamento

3. **Análise Temporal**
   - Tendências anuais
   - Comparativos mensais
   - Calendário de calor

4. **Detalhamento**
   - Análise por funcionário
   - Filtros avançados
   - Métricas específicas

## 📊 Fórmulas DAX Principais

```dax
Taxa de Absenteísmo = 
DIVIDE(
    COUNTROWS('Absences'),
    DISTINCTCOUNT('Employees'[ID])
) * 100

Custo Total Faltas = 
SUMX(
    'Absences',
    'Absences'[duration_hours] * RELATED('Employees'[compensation_per_hour])
)
```

## 🚀 Como Usar

1. **Configuração do Banco de Dados**
   ```sql
   -- Execute os scripts de criação de tabelas
   -- Import os dados iniciais
   ```

2. **Power BI**
   - Abra o arquivo .pbix
   - Configure a conexão com o banco
   - Atualize os dados

3. **Relatórios**
   - Configure a periodicidade
   - Defina os destinatários
   - Ajuste os alertas

## 📋 Pré-requisitos

- SQL Server 2019+
- Power BI Desktop
- Acesso ao banco de dados
- Permissões adequadas

## 🔄 Processo de Atualização

1. Dados são atualizados diariamente
2. Alertas são processados em tempo real
3. Relatórios são gerados semanalmente
4. Backup realizado diariamente

## 📌 Versão

1.0.0 - Versão inicial com funcionalidades básicas

## ✒️ Autor

* **José Carlos Carneiro** - *Desenvolvimento Inicial*

## 📄 Licença

Este projeto está sob a licença MIT - veja o arquivo [LICENSE.md](LICENSE.md) para detalhes



## 📚 Referências

* [Documentação Power BI](https://learn.microsoft.com/en-us/power-bi/)
* [Documentação SQL Server](https://learn.microsoft.com/en-us/sql/)
* [DAX Guide](https://dax.guide/)

---
⌨️ com ❤️ por José Carlos Carneiro 😊
