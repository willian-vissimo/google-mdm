# Explorer Restart

Reinicia o `explorer.exe` as 10:00, 14:00 e 18:00 no contexto do usuario conectado.

## Comportamento

- Nao acorda a maquina.
- Nao executa horarios perdidos.
- Executa somente quando o usuario correspondente esta conectado.
- Fecha janelas do Explorador e pode interromper copias iniciadas por ele.
- A tarefa de cada usuario e registrada no proximo logon depois da instalacao.

## Pacote

```text
Arquivo: release\Evino-Explorer-Restart-1.0.0.msi
Versao: 1.0.0
ProductCode: {EAE6D451-9055-4F80-B46F-75B758310A31}
SHA-256: 0E07F122C56657128634ED44F78103CBAB26DA1441B93808C91D57E382F37643
```

## Google Admin

Crie uma configuracao personalizada do Windows na OU de teste.

```text
Nome: Evino - Reiniciar Windows Explorer
OMA-URI: ./Device/Vendor/MSFT/EnterpriseDesktopAppManagement/MSI/%7BEAE6D451-9055-4F80-B46F-75B758310A31%7D/DownloadInstall
Tipo de dado: String
```

Depois que este repositorio estiver publico, a URL esperada sera:

```text
https://raw.githubusercontent.com/willian-vissimo/google-mdm/refs/heads/main/windows-maintenance/explorer-restart/release/Evino-Explorer-Restart-1.0.0.msi
```

Se o proprietario, repositorio ou branch forem diferentes, ajuste a URL antes de salvar a configuracao.

Use este XML:

```xml
<Data>
  <MsiInstallJob id="{D7B2270F-F147-4D99-A750-3611B5D92D36}">
    <Product Version="1.0.0">
      <Download>
        <ContentURLList>
          <ContentURL>https://raw.githubusercontent.com/willian-vissimo/google-mdm/refs/heads/main/windows-maintenance/explorer-restart/release/Evino-Explorer-Restart-1.0.0.msi</ContentURL>
        </ContentURLList>
      </Download>
      <Validation>
        <FileHash>0E07F122C56657128634ED44F78103CBAB26DA1441B93808C91D57E382F37643</FileHash>
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
</Data>
```

## Build

```powershell
.\build.ps1
```

O script baixa o WiX Toolset no diretorio temporario, grava intermediarios em `dist` e o MSI final em `release`.

## Validacao

Depois da sincronizacao do MDM, confirme a instalacao em **Aplicativos instalados** ou com o ProductCode. A tarefa sera criada quando o usuario entrar novamente na sessao:

```powershell
Get-ScheduledTask -TaskName "Evino-ExplorerRestart-*"
```

Os tres gatilhos devem aparecer como `10:00`, `14:00` e `18:00`. O resultado `0` em `LastTaskResult` indica execucao bem-sucedida:

```powershell
Get-ScheduledTask -TaskName "Evino-ExplorerRestart-*" | Get-ScheduledTaskInfo
```

Para desinstalacao local:

```powershell
msiexec.exe /x "{EAE6D451-9055-4F80-B46F-75B758310A31}" /qn /norestart
```

## Seguranca

O MSI atual nao possui assinatura digital. Se ele for assinado posteriormente, recalcule o SHA-256 e atualize o XML, pois a assinatura altera o arquivo.
