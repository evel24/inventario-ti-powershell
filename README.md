# Inventário Automatizado de Ativos de TI — PowerShell

Projeto de portfólio voltado para vagas de **Suporte de TI, Service Desk, N1/N2 e Infraestrutura**.

## Objetivo

Automatizar a coleta de informações básicas de estações Windows para facilitar inventário, conferência de ativos e diagnóstico inicial.

O script coleta:

- Hostname
- Usuário atual
- Fabricante e modelo
- Número de série
- Processador
- Memória RAM
- Sistema operacional, versão e build
- Arquitetura do sistema
- Endereço IPv4
- Capacidade total e espaço livre em disco
- Data/hora do último boot
- Data da coleta
- Status da coleta e mensagem de erro, quando houver

## Tecnologias

- PowerShell
- WMI/CIM (`Get-CimInstance`)
- Windows
- CSV
- Automação de rotinas de suporte
- Gestão de ativos de TI

## Requisitos

- Windows 10/11 ou Windows Server
- PowerShell 5.1 ou PowerShell 7+
- Para coleta remota, o ambiente deve permitir consultas CIM/WinRM e o usuário deve possuir as permissões necessárias.

## Como usar

### 1. Abra o PowerShell

Entre na pasta do projeto:

```powershell
cd C:\caminho\para\inventario-ti-powershell
```

### 2. Execute para o computador local

```powershell
.\Get-ITInventory.ps1
```

O resultado será salvo em:

```text
inventario-ti.csv
```

### 3. Escolha outro arquivo de saída

```powershell
.\Get-ITInventory.ps1 -OutputPath .\saida\inventario.csv
```

### 4. Coleta de mais de um computador

```powershell
.\Get-ITInventory.ps1 -ComputerName PC-001,PC-002,PC-003 -OutputPath .\inventario.csv
```

> A coleta remota depende das permissões e configurações de rede/WinRM do ambiente.

## Exemplo de saída

Veja `sample_inventory.csv`. Os dados são fictícios e servem apenas para demonstrar a estrutura do CSV.

## O que este projeto demonstra

- Uso de PowerShell para automatizar tarefas repetitivas de suporte
- Coleta de informações de hardware e sistema operacional
- Tratamento de falhas sem interromper toda a execução
- Geração de relatórios em CSV
- Organização de informações para inventário de ativos
- Noções de coleta remota em ambiente Windows

## Como explicar em uma entrevista

> Criei um script em PowerShell para automatizar o inventário de estações Windows. Ele consulta informações de hardware, sistema operacional, rede e armazenamento utilizando CIM, trata erros individualmente e exporta tudo para CSV. A ideia foi simular uma rotina comum de Service Desk e infraestrutura, reduzindo coleta manual de dados.

## Próximas melhorias

- Exportar também para JSON
- Gerar dashboard no Power BI com os dados coletados
- Adicionar data de garantia e patrimônio a partir de uma base externa
- Integrar com Active Directory / Microsoft Entra ID
- Criar histórico de inventário para comparar mudanças de hardware
- Enviar o resultado para uma API ou banco de dados

## Estrutura

```text
inventario-ti-powershell/
├── Get-ITInventory.ps1
├── README.md
├── sample_inventory.csv
├── linkedin-text.md
└── docs/
    └── runbook.md
```

## Observação

Este projeto é um laboratório de portfólio. Em ambientes corporativos, respeite políticas de segurança, permissões e procedimentos internos antes de realizar coleta remota.
