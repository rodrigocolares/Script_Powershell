3 Scripts criado em powershell:

- install_plesk.ps1 ( Script para instalação automatizada do painel plesk com os seguintes passos:
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
- Limpar_WinSxS.ps1 (Limpeza segura da pasta WinSxS usando DISM)
- Limpar_msi.ps1 (Limpeza segura do diretório Installer)
