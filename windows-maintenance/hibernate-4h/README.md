# Hibernation After 4 Hours

Habilita a hibernacao e configura `14400` segundos de inatividade em tomada e bateria.

- Preserva aplicativos e documentos abertos.
- Nao usa horarios fixos nem exibe avisos.
- Cria uma tarefa `SYSTEM` na inicializacao para reaplicar a configuracao.
- A desinstalacao remove a tarefa e desativa os timeouts automaticos, mas mantem o recurso de hibernacao habilitado.

ProductCode:

```text
{30E5255A-F02C-4E89-B225-9EC590C10650}
```

OMA-URI:

```text
./Device/Vendor/MSFT/EnterpriseDesktopAppManagement/MSI/%7B30E5255A-F02C-4E89-B225-9EC590C10650%7D/DownloadInstall
```

Execute `build.ps1` e use o SHA-256 retornado no XML `DownloadInstall`.

Artefato atual:

```text
dist\Evino-Hibernation-4h-1.0.0.msi
SHA-256: C0CE2E24CA4785EA143A3EE94BB09A4992A71970B03FAD7D7A385582B5720319
```

O MSI ainda nao esta assinado. Assine antes da implantacao geral e recalcule o hash, pois a assinatura altera o arquivo.
