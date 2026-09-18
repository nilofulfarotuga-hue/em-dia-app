# BLOCO 5 — Correção das contas, com testes (2026-09-18)

> Missão `em-dia-tudo-2026-09-17`. Ordem: «as contas que o Danilo mandou fixar, cada uma com
> teste e com a fonte oficial escrita no teste; nenhuma build vai à Play com um deles vermelho».

## O que ficou feito

- `test/unit/contas_com_fonte_test.dart` — nove testes F1–F9, um por conta, **com a fonte
  oficial (lei/artigo e URL) no nome do próprio teste**, para que quem vir um vermelho no CI saiba
  de imediato de onde vem o número. Os valores esperados foram calculados à mão a partir da fonte,
  nunca copiados do código.
- O portão do CI já existia e continua a ser o mesmo:
  `.github/workflows/build_android.yml` → passo «Testes unitários das regras»
  (`flutter test test/unit -r expanded`) corre **antes** do «Build appbundle (release)». Um teste
  vermelho pára o workflow e a Play não recebe build.

## As nove contas e as fontes

| # | Conta | Fonte |
|---|---|---|
| F1 | Segurança Social do independente = 70 % × 21,4 % → **179,76 €** para 1.200 €/mês | Código Contributivo (Lei 110/2009) art. 162.º (base 70 %) e 168.º (taxa 21,4 %) |
| F2 | IVA isento abaixo de **15.000 €**/ano | CIVA art. 53.º (DL 35/2025) |
| F3 | Retenção na fonte **23 %** | CIRS art. 101.º n.º 1 (desde 2024) |
| F4 | Isenção de Segurança Social no 1.º ano: **12 meses** a contar do início | Código Contributivo art. 145.º; Guia Prático do ISS «Trabalhadores Independentes» |
| F5 | Prazo do Estado a fim-de-semana/feriado → **dia útil seguinte** | AT, Resumo anual 2026, nota a); SS Direta |
| F6 | IUC até ao **fim do mês da matrícula**, todos os anos | Código do IUC art. 17.º |
| F7 | Inspeção: ligeiros aos **4, 6 e 8 anos**, depois anual; **TVDE anual** | IMT; Lei 45/2018 art. 12.º n.º 5 |
| F8 | IRS Jovem: ≤ 35 anos, 10 anos, **100/75/50/25 %**, limite 55 × IAS | CIRS art. 12.º-B (Lei 45-A/2024) |
| F9 | Contrato: retenção vem do recibo; SS **11 %**; IRS do ano pelos escalões | ISS «Taxas Contributivas»; CIRS art. 68.º |

Todos os números vivem na tabela `regras_legais` (espelho `RegrasLegais.padrao2026()`), com
`fonte_url`, `confianca` e `verificado_em` — os testes leem-nos por `RegrasLegais`, nunca por
constantes soltas (regra 2 do CLAUDE.md). Detalhe de cada regra em `docs/REGRAS-PT-2026.md`.

## Prova (saída literal, 2026-09-18 14:40)

```
$ flutter test test/unit/contas_com_fonte_test.dart -r expanded
F1 Segurança Social = 70 % × 21,4 % → 179,76 € para 1.200 €/mês (Código Contributivo, Lei 110/2009, art. 162.º base 70 % e art. 168.º taxa 21,4 %; h…
F2 IVA isento abaixo do limiar de 15.000 € (CIVA art. 53.º, DL 35/2025; https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_r…
F3 retenção na fonte de 23 % (CIRS art. 101.º n.º 1; taxa desde 2024; https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_re…
F4 isenção de Segurança Social no 1.º ano: 12 meses a contar do início (Código Contributivo art. 145.º; Guia Prático do ISS «Trabalhadores Independente…
F5 prazo do Estado a fim-de-semana/feriado passa ao dia útil seguinte (AT, Resumo anual 2026, nota a) «…pode ser cumprida até ao dia útil seguinte»; SS, …
F6 IUC paga-se até ao fim do mês da matrícula, todos os anos (Código do IUC art. 17.º; Portal das Finanças → IUC → Pagar)
F7 inspeção pela idade: ligeiros aos 4, 6 e 8 anos, depois anual; TVDE anual (IMT, tipos de inspeção; Lei 45/2018 art. 12.º n.º 5; https://www.imt-ip.pt/s…
F8 IRS Jovem: ≤ 35 anos, 10 anos, 100/75/50/25 %, limite 55 × IAS (CIRS art. 12.º-B, Lei 45-A/2024; https://info.portaldasfinancas.gov.pt/pt/informacao_fisc…
F9 contrato: a retenção vem do recibo (não de tabelas copiadas), a SS é 11 % e o IRS do ano acerta-se pelos escalões (ISS «Taxas Contributivas» 11 %/23,7…
All tests passed!
```

Portão do CI (`.github/workflows/build_android.yml`, linhas 163–172):

```yaml
      - name: Flutter analyze (0 erros)
        run: flutter analyze --no-fatal-infos

      - name: Testes unitários das regras
        run: flutter test test/unit -r expanded

      - name: Build appbundle (release)
```

## O que não se fez, e porquê

- Não se acrescentou um portão novo ao CI: o que existe já pára a build com um vermelho. Pôr um
  segundo passo igual seria só demorar mais.
- Os números não foram «ajustados para bater certo»: F1 deu 179,76 € à primeira porque a base
  (70 %) e a taxa (21,4 %) já estavam certas na tabela desde o Bloco 1.
