# Explorer Restart

Reinicia o `explorer.exe` as 10:00, 14:00 e 18:00 no contexto do usuario conectado.

## Comportamento

- Nao acorda a maquina.
- Nao executa horarios perdidos.
- Executa somente quando o usuario correspondente esta conectado.
- Fecha janelas do Explorador e pode interromper copias iniciadas por ele.
- Registra a tarefa imediatamente para usuarios conectados no momento da instalacao.
- Registra a tarefa no logon para usuarios que entrarem depois da instalacao.

## Pacote

```text
Arquivo: release\Evino-Explorer-Restart-1.1.0.msi
Versao: 1.1.0
ProductCode: {33236F03-630E-470A-994C-8AAD1EAD525C}
SHA-256: 6F1BDC8AE015181EF2509D876C1E09AD76E4A7B3EA9DA32084A743F02295A6CA
```

## Google Admin

Crie uma configuracao personalizada do Windows na OU de teste.

```text
Nome: Evino - Reiniciar Windows Explorer
OMA-URI: ./Device/Vendor/MSFT/EnterpriseDesktopAppManagement/MSI/%7B33236F03-630E-470A-994C-8AAD1EAD525C%7D/DownloadInstall
Tipo de dado: String (XML)
```

Depois que este repositorio estiver publico, a URL esperada sera:

```text
https://github.com/willian-vissimo/google-mdm/raw/refs/heads/main/windows-maintenance/explorer-restart/release/Evino-Explorer-Restart-1.1.0.msi
```

Se o proprietario, repositorio ou branch forem diferentes, ajuste a URL antes de salvar a configuracao.

Clique em **Upload XML** e selecione:

```text
release\Evino-Explorer-Restart-1.1.0.xml
```

Conteudo do arquivo:

```xml
<MsiInstallJob id="{87146F72-8BBF-489E-B443-2FEC2E888C60}">
  <Product Version="1.1.0">
    <Download>
      <ContentURLList>
        <ContentURL>https://github.com/willian-vissimo/google-mdm/raw/refs/heads/main/windows-maintenance/explorer-restart/release/Evino-Explorer-Restart-1.1.0.msi</ContentURL>
      </ContentURLList>
    </Download>
    <Validation>
      <FileHash>6F1BDC8AE015181EF2509D876C1E09AD76E4A7B3EA9DA32084A743F02295A6CA</FileHash>
    </Validation>
    <Enforcement>
      <CommandLine>/qn /norestart</CommandLine>
      <TimeOut>5</TimeOut>
      <RetryCount>3</RetryCount>
      <RetryInterval>5</RetryInterval>
      <DownloadFromAad>0</DownloadFromAad>
    </Enforcement>
  </Product>
</MsiInstallJob>
```

## Build

```powershell
.\build.ps1
```

O script baixa o WiX Toolset no diretorio temporario, grava intermediarios em `dist` e o MSI final em `release`.

## Validacao

Antes de aplicar a versao `1.1.0`, desative a configuracao personalizada da versao `1.0.0`. Depois da sincronizacao do MDM, confirme a instalacao em **Aplicativos instalados** ou com o ProductCode. Se ja houver um usuario conectado, a tarefa sera criada durante a instalacao:

```powershell
Get-ScheduledTask -TaskName "Evino-ExplorerRestart-*"
```

Os tres gatilhos devem aparecer como `10:00`, `14:00` e `18:00`. O resultado `0` em `LastTaskResult` indica execucao bem-sucedida:

```powershell
Get-ScheduledTask -TaskName "Evino-ExplorerRestart-*" | Get-ScheduledTaskInfo
```

Para desinstalacao local:

```powershell
msiexec.exe /x "{33236F03-630E-470A-994C-8AAD1EAD525C}" /qn /norestart
```

## Seguranca

O MSI atual nao possui assinatura digital. Se ele for assinado posteriormente, recalcule o SHA-256 e atualize o XML, pois a assinatura altera o arquivo.
