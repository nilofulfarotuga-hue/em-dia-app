# B1 - marca

## Referencias vistas

Fontes publicas consultadas:

- `https://www.revolut.com/` - promessa principal "Banking & Beyond", escala e confianca.
- `https://monzo.com/` - frase humana "Spend your money on life, not your life on money" e cor memoravel.
- `https://www.rocketmoney.com/` - promessa direta "The money app that works for you" e controlo de subscricoes/gastos.
- `https://www.meifacil.com/` - pagina Neon/MEI Facil com linguagem para pequenos trabalhadores e foco em tudo num so sitio.

Direcao escolhida: calendario com visto, verde forte, linguagem de alivio e controlo, sem mascote generica.

## Geracao local executada

Comando:

```powershell
python tool\marca\desenhar.py propostas
python tool\marca\desenhar.py icones --n 1
python tool\marca\desenhar.py feature --n 1
python tool\loja\capturas.py
```

Saida literal relevante:

```text
ok proposta-1.png (1024, 1024) 88647 bytes
ok proposta-2.png (1024, 1024) 225008 bytes
ok proposta-3.png (1024, 1024) 154818 bytes
ok proposta-4.png (1024, 1024) 112341 bytes
ok proposta-5.png (1024, 1024) 102368 bytes
ok docs\marca\escolhida.png (1024, 1024) RGBA 88647 bytes
ok assets\branding\icon.png (1024, 1024) RGB 63600 bytes
ok assets\branding\icon_foreground.png (1024, 1024) RGBA 30232 bytes
ok docs\marca\feature-graphic-1024x500.png (1024, 500) 103700 bytes
icone      icone-512.png  (512, 512)  39 KB
feature    feature-1024x500.png  (1024, 500)  43 KB
captura    captura-1.png  (1080, 1920)  264 KB
captura    captura-2.png  (1080, 1920)  217 KB
captura    captura-3.png  (1080, 1920)  316 KB
captura    captura-4.png  (1080, 1920)  299 KB
captura    captura-5.png  (1080, 1920)  215 KB
captura    captura-6.png  (1080, 1920)  257 KB
captura    captura-7.png  (1080, 1920)  360 KB
captura    captura-8.png  (1080, 1920)  291 KB
```

## INPI e Play

Fonte publica INPI consultada: `https://justica.gov.pt/Registos/Propriedade-Industrial/Marca`.

Saida literal relevante da pagina:

```text
Antes de fazer o pedido de registo, deve certificar-se que nao existe uma marca igual ou semelhante a que quer registar. A pesquisa e gratuita e pode ser feita por classe, requerente ou sinal.
```

Pesquisa publica Play por `Em Dia`: `https://play.google.com/store/search?q=Em%20Dia&c=apps`.

Resultado: a pagina publica devolveu apps como `Dia Supermercado online y Club`, `Day One Diary`, Google/Meta/etc.; nao apareceu a app `pt.emdia.app` como resultado publico nesta pesquisa.

## Bloqueios honestos

Nao foram feitas as 10 propostas em Gemini pago e ChatGPT web porque o Chrome autenticado ficou bloqueado no B-1. Nao foi feito juiz visual em 3 conversas limpas. Nao foi feito video nem upload YouTube. Nao foi preenchido pedido INPI ate ao botao de pagar. Estes pontos ficam pendentes por bloqueio de navegador/pagamento, nao por decisao de produto.

## e2e_log

Nao gravado por esta sessao: Auth local recusou login com `captcha_failed` no B-1.
