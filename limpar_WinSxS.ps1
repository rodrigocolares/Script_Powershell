# Limpeza segura da pasta WinSxS usando DISM

Write-Host "Iniciando limpeza do WinSxS..." -ForegroundColor Cyan

# Verifica integridade da imagem
Write-Host "Verificando integridade da imagem..." -ForegroundColor Yellow
DISM.exe /Online /Cleanup-Image /ScanHealth

# Repara a imagem se necessário
Write-Host "Reparando a imagem (se necessário)..." -ForegroundColor Yellow
DISM.exe /Online /Cleanup-Image /RestoreHealth

# Limpa componentes substituídos
Write-Host "Limpando componentes substituídos..." -ForegroundColor Yellow
DISM.exe /Online /Cleanup-Image /StartComponentCleanup

# Limpeza agressiva (opcional)
Write-Host "Executando limpeza profunda (ResetBase)..." -ForegroundColor Yellow
DISM.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase

Write-Host "Limpeza concluída com sucesso!" -ForegroundColor Green
