# Windows Maintenance Packages

As automacoes foram separadas em pacotes independentes:

- `explorer-restart`: reinicia o Windows Explorer as 10:00, 14:00 e 18:00.
- `hibernate-4h`: habilita a hibernacao e configura quatro horas de inatividade em tomada e bateria.

O pacote combinado antigo `Evino Workstation Maintenance 1.0.0` foi descontinuado. Ele deve ser removido antes da instalacao dos novos pacotes para excluir os avisos e a reinicializacao obrigatoria das 20:00-23:00.

ProductCode legado para remocao:

```text
{A650F4CC-7C06-4AB6-BB3D-4F713A55A301}
```

Cada subdiretorio contem seu proprio MSI, ProductCode, script de build e instrucoes para o Google MDM.
