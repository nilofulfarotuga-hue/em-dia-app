# Fecho mensal

Os ficheiros de fecho mensal ficam no bucket privado `fecho-mensal`, com esta estrutura:

```text
fecho-mensal/<app>/AAAA-MM/
  extrato-google.csv
  resumo.json
  folha-de-rosto.md
```

Neste momento, só o `em-dia` corre automaticamente. O cron chama a Edge Function `fecho-mensal` no dia 1 de cada mês e fecha o mês anterior.

O `bora` fica apenas preparado na estrutura de pastas. Para o Bora será preciso outro projeto Supabase, outra conta Google Play e outro segredo de bucket. Esta tarefa não inclui código do Bora.

Se a Google Play ainda não tiver bucket configurado, ou se o extrato vier num formato que o leitor não reconhece, o fecho não inventa valores. A função grava a folha de rosto com o motivo e deixa os números sem dados.
