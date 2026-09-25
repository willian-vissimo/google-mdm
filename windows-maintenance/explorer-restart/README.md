# Explorer Restart

Reinicia o `explorer.exe` as 10:00, 14:00 e 18:00 no contexto do usuario conectado.

- Nao acorda a maquina.
- Nao executa horarios perdidos.
- Fecha janelas do Explorador e pode interromper copias iniciadas por ele.
- As tarefas de usuario sao registradas no proximo logon.

ProductCode:

```text
{EAE6D451-9055-4F80-B46F-75B758310A31}
```

OMA-URI:

```text
./Device/Vendor/MSFT/EnterpriseDesktopAppManagement/MSI/%7BEAE6D451-9055-4F80-B46F-75B758310A31%7D/DownloadInstall
```

Execute `build.ps1` e use o SHA-256 retornado no XML `DownloadInstall`.

Artefato atual:

```text
dist\Evino-Explorer-Restart-1.0.0.msi
SHA-256: 6D0B8D31326D7FCCF74FFFCE5BE122DBA4C7B4CBBAAFF860ECDD6761F0913BFE
```

O MSI ainda nao esta assinado. Assine antes da implantacao geral e recalcule o hash, pois a assinatura altera o arquivo.
