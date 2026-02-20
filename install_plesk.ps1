<#
.SYNOPSIS
    Instalação completa do Plesk em Windows Server 2022 com:
    - Diretórios personalizados
    - Logs detalhados
    - Validação de portas
    - Reboot opcional

.DESCRIPTION
    - Valida execução como administrador
    - Confirma Windows Server 2022
    - Baixa e instala o Plesk (instalação completa)
    - Define diretórios personalizados:
        * Diretório de instalação
        * Diretório do CLI
        * Diretório dos utilitários admin
        * Diretório de vhosts (E:\vhosts)
    - Gera logs detalhados
    - Configura senha do admin
    - Reboot opcional
#>

# ==========================
# Configurações iniciais
# ==========================

$ErrorActionPreference = "Stop"

# Caminhos
$logFolder       = "C:\PleskInstallLogs"
$logFile         = Join-Path $logFolder "PleskInstall_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$installerPath   = "C:\plesk-installer.exe"
$pleskInstallerUrl = "https://autoinstall-win.plesk.com/plesk-installer.exe"

# Diretórios personalizados
$pleskInstallDir = "C:\Program Files (x86)\Parallels\Plesk"
$pleskBinDir     = "C:\Program Files (x86)\Parallels\Plesk\bin"
$pleskAdminBin   = "C:\Program Files (x86)\Parallels\Plesk\admin\bin"
$pleskVhostsDir  = "E:\vhosts"

# Senha do admin do Plesk
$adminPassword   = "SenhaForteAqui123!"

# Reboot automático ao final
$enableReboot = $true

# Portas essenciais
$requiredPorts = @(80, 443, 8443)

# ==========================
# Funções auxiliares
# ==========================

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] [$Level] $Message"
    Write-Host $line
    Add-Content -Path $logFile -Value $line
}

function Test-IsAdmin {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-IsWindowsServer2022 {
    $os = Get-CimInstance Win32_OperatingSystem
    return ($os.Caption -like "*Windows Server 2022*")
}

function Test-PortAvailability {
    param([int]$Port)
    $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    return -not $connection
}

# ==========================
# Preparação de ambiente
# ==========================

if (-not (Test-Path $logFolder)) {
    New-Item -Path $logFolder -ItemType Directory | Out-Null
}

Start-Transcript -Path $logFile -Append | Out-Null

try {
    Write-Log "Iniciando script de instalação completa do Plesk..."

    # Verificar admin
    if (-not (Test-IsAdmin)) {
        Write-Log "O script não está sendo executado como Administrador." "ERROR"
        throw "Execute o PowerShell como Administrador."
    }

    # Verificar SO
    if (-not (Test-IsWindowsServer2022)) {
        Write-Log "O sistema operacional não é Windows Server 2022." "ERROR"
        throw "Este script foi preparado para Windows Server 2022."
    }

    # ==========================
    # Validação de portas
    # ==========================

    Write-Log "Validando portas essenciais..."

    foreach ($port in $requiredPorts) {
        if (-not (Test-PortAvailability -Port $port)) {
            Write-Log "A porta $port está em uso. O Plesk pode não funcionar corretamente." "ERROR"
            throw "Libere a porta $port antes de continuar."
        } else {
            Write-Log "Porta $port está livre."
        }
    }

    # ==========================
    # Criar diretório de vhosts
    # ==========================

    if (-not (Test-Path $pleskVhostsDir)) {
        Write-Log "Criando diretório de vhosts em $pleskVhostsDir..."
        New-Item -Path $pleskVhostsDir -ItemType Directory | Out-Null
    }

    # ==========================
    # Download do instalador
    # ==========================

    Write-Log "Baixando instalador do Plesk..."
    Invoke-WebRequest -Uri $pleskInstallerUrl -OutFile $installerPath
    Unblock-File -Path $installerPath

    # ==========================
    # Instalação completa com diretórios personalizados
    # ==========================

    $pleskInstallerLog = Join-Path $logFolder "PleskInstaller_$(Get-Date -Format 'yyyyMMdd_HHmmss').xml"

    Write-Log "Iniciando instalação COMPLETA do Plesk com diretórios personalizados..."

    $arguments = @(
        "--select-release-latest",
        "--installation-type=Full",
        "--enable-xml-output",
        "--silent",
        "--log-file=$pleskInstallerLog",
        "--install-dir=$pleskInstallDir",
        "--bin-dir=$pleskBinDir",
        "--admin-bin-dir=$pleskAdminBin",
        "--vhosts-dir=$pleskVhostsDir"
    )

    Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait -PassThru

    Write-Log "Instalação concluída com sucesso."

    # ==========================
    # Configuração inicial
    # ==========================

    $pleskExe = "$pleskBinDir\plesk.exe"

    Write-Log "Configurando senha do admin..."

    & $pleskExe "bin" "admin" "--set-password" "-passwd" $adminPassword

    Write-Log "Senha configurada com sucesso."
    Write-Log "Acesse o painel em: https://SEU-IP:8443"

    # ==========================
    # Reboot opcional
    # ==========================

    if ($enableReboot) {
        Write-Log "Reboot automático habilitado. Reiniciando servidor..."
        Restart-Computer -Force
    } else {
        Write-Log "Reboot automático desabilitado."
    }

} catch {
    Write-Log "Erro durante a execução: $_" "ERROR"
    throw
} finally {
    Write-Log "Encerrando transcript."
    Stop-Transcript | Out-Null
}
