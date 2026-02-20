# Caminho da pasta Installer
$installerFolder = Join-Path $env:windir "Installer"

# Busca arquivos MSI e MSP
$files = Get-ChildItem -Path $installerFolder -Recurse -Include *.msi, *.msp -ErrorAction SilentlyContinue

if (-not $files) {
    Write-Host "Nenhum arquivo MSI/MSP encontrado." -ForegroundColor Yellow
    return
}

Write-Host "Foram encontrados $($files.Count) arquivos." -ForegroundColor Cyan
Write-Host "ATENÇÃO: Excluir arquivos desta pasta pode corromper instalações do Windows e programas." -ForegroundColor Red
$confirm = Read-Host "Deseja realmente continuar? (S/N)"

if ($confirm -ne "S") {
    Write-Host "Operação cancelada." -ForegroundColor Yellow
    return
}

# Cria log
$logPath = "$env:TEMP\InstallerCleanup_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
Write-Host "Gerando log em: $logPath" -ForegroundColor Cyan

foreach ($file in $files) {
    try {
        Write-Host "Excluindo: $($file.FullName)" -ForegroundColor White
        Add-Content -Path $logPath -Value "Excluído: $($file.FullName)"
        Remove-Item -Path $file.FullName -Force
    }
    catch {
        Write-Host "Erro ao excluir: $($file.FullName)" -ForegroundColor Red
        Add-Content -Path $logPath -Value "ERRO: $($file.FullName) - $_"
    }
}

Write-Host "Processo concluído." -ForegroundColor Green
Write-Host "Log salvo em: $logPath"