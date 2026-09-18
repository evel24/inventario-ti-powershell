<#
.SYNOPSIS
    Coleta informações de inventário de computadores Windows e exporta para CSV.

.DESCRIPTION
    Projeto de portfólio voltado para Suporte de TI / Service Desk.
    O script coleta dados básicos de hardware, sistema operacional, rede e armazenamento.
    Pode ser executado localmente ou contra computadores remotos acessíveis via CIM/WinRM.

.PARAMETER ComputerName
    Um ou mais nomes de computadores. Por padrão, coleta o computador local.

.PARAMETER OutputPath
    Caminho do arquivo CSV de saída.

.EXAMPLE
    .\Get-ITInventory.ps1

.EXAMPLE
    .\Get-ITInventory.ps1 -OutputPath .\inventario.csv

.EXAMPLE
    .\Get-ITInventory.ps1 -ComputerName PC-001,PC-002 -OutputPath .\inventario.csv
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string[]]$ComputerName = @($env:COMPUTERNAME),

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ".\inventario-ti.csv"
)

$results = foreach ($computer in $ComputerName) {
    try {
        Write-Host "Coletando dados de $computer..." -ForegroundColor Cyan

        $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $computer -ErrorAction Stop
        $bios           = Get-CimInstance -ClassName Win32_BIOS -ComputerName $computer -ErrorAction Stop
        $os             = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computer -ErrorAction Stop
        $cpu            = Get-CimInstance -ClassName Win32_Processor -ComputerName $computer -ErrorAction Stop |
                          Select-Object -First 1
        $disks          = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $computer -Filter "DriveType=3" -ErrorAction Stop

        $diskTotalGB = [math]::Round((($disks | Measure-Object -Property Size -Sum).Sum / 1GB), 2)
        $diskFreeGB  = [math]::Round((($disks | Measure-Object -Property FreeSpace -Sum).Sum / 1GB), 2)

        $ipAddresses = @()
        try {
            $networkConfigs = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -ComputerName $computer `
                -Filter "IPEnabled=True" -ErrorAction Stop

            foreach ($net in $networkConfigs) {
                if ($net.IPAddress) {
                    $ipAddresses += $net.IPAddress | Where-Object {
                        $_ -match '^\d{1,3}(\.\d{1,3}){3}$' -and $_ -notmatch '^169\.254\.'
                    }
                }
            }
        }
        catch {
            $ipAddresses = @()
        }

        [PSCustomObject]@{
            Hostname          = $computerSystem.Name
            UsuarioAtual      = $computerSystem.UserName
            Fabricante        = $computerSystem.Manufacturer
            Modelo            = $computerSystem.Model
            NumeroSerie       = $bios.SerialNumber
            Processador       = $cpu.Name
            RAM_GB            = [math]::Round(($computerSystem.TotalPhysicalMemory / 1GB), 2)
            SistemaOperacional= $os.Caption
            VersaoSO          = $os.Version
            BuildSO           = $os.BuildNumber
            Arquitetura       = $os.OSArchitecture
            EnderecoIP        = ($ipAddresses | Sort-Object -Unique) -join "; "
            DiscoTotal_GB     = $diskTotalGB
            DiscoLivre_GB     = $diskFreeGB
            UltimoBoot        = $os.LastBootUpTime
            DataColeta        = Get-Date
            StatusColeta      = "OK"
            Erro              = ""
        }
    }
    catch {
        [PSCustomObject]@{
            Hostname          = $computer
            UsuarioAtual      = ""
            Fabricante        = ""
            Modelo            = ""
            NumeroSerie       = ""
            Processador       = ""
            RAM_GB            = ""
            SistemaOperacional= ""
            VersaoSO          = ""
            BuildSO           = ""
            Arquitetura       = ""
            EnderecoIP        = ""
            DiscoTotal_GB     = ""
            DiscoLivre_GB     = ""
            UltimoBoot        = ""
            DataColeta        = Get-Date
            StatusColeta      = "ERRO"
            Erro              = $_.Exception.Message
        }
    }
}

$parent = Split-Path -Parent $OutputPath
if ($parent -and -not (Test-Path $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
}

$results | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "Inventário concluído." -ForegroundColor Green
Write-Host "Arquivo gerado: $((Resolve-Path $OutputPath).Path)" -ForegroundColor Green
Write-Host "Computadores processados: $($results.Count)" -ForegroundColor Green
