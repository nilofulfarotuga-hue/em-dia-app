#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Preenche e envia a Segurança dos Dados (Data safety) da Play, pela API.

Porquê pela API: a Play Console é AngularDart e o browser automatizado não é de
confiança nela (cicatriz 2026-09-06). O endpoint
`POST /androidpublisher/v3/applications/{pacote}/dataSafety` aceita o CONTEÚDO
do CSV do formulário — o mesmo ficheiro que se descarrega e importa na consola.

O modelo oficial está em `docs/loja/play/data-safety-modelo.csv` (descarregado
de support.google.com, artigo 10787469). Tem 763 linhas: uma por resposta
possível. Este script escreve só a coluna «Response value» e deixa o resto igual.

O QUE A APP RECOLHE (verificado no código, não adivinhado — ver `--porque`):
  e-mail e id de conta (entrar), valores de rendimento/imposto e custos do carro,
  matrícula e datas do carro/carta/residência, fotos de comprovativos, o que a
  pessoa escreve ao assistente e ao suporte, e o identificador do aparelho para
  os avisos. NADA de localização (regra 9 do CLAUDE.md) e NADA é partilhado com
  terceiros — o Supabase e o Firebase são fornecedores que tratam os dados por
  nossa conta.

FALTA UMA COISA (2026-09-06): o modelo público da Google está DESATUALIZADO em
relação à API. Com ele, o envio morre em:

    HTTP 400 — Invalid safety labels declaration:
    Response missing for PSL_SUPPORTED_ACCOUNT_CREATION_METHODS

Essa pergunta não existe no modelo público (o mesmo ficheiro em 14 idiomas) e a
Google não publica os IDs de resposta dela — 20 candidatos plausíveis foram
todos recusados com «Invalid response ID», e sem ID a linha dá «Response ID
missing». O caminho certo é **exportar o CSV atual da consola**
(Play Console → Política → Segurança dos dados → Exportar para CSV) e correr:

    python tool/play/data_safety.py --modelo <ficheiro-exportado.csv> --aplicar

O script trata das perguntas que conhece e deixa as outras exactamente como
vieram da exportação (avisa quais são).

Uso:  python tool/play/data_safety.py              # ensaio: escreve o CSV, não envia
      python tool/play/data_safety.py --aplicar    # envia para a Play
      python tool/play/data_safety.py --porque     # explica cada escolha
      python tool/play/data_safety.py --modelo X.csv [--aplicar]
"""
from __future__ import annotations

import csv
import datetime as dt
import io
import sys
from pathlib import Path

for fluxo in (sys.stdout, sys.stderr):
    try:
        fluxo.reconfigure(encoding="utf-8", errors="replace")
    except Exception:  # noqa: BLE001
        pass

sys.path.insert(0, str(Path(__file__).parent))
from api import BASE, ErroPlay, Play  # noqa: E402

RAIZ = Path(__file__).resolve().parents[2]
MODELO = RAIZ / "docs" / "loja" / "play" / "data-safety-modelo.csv"
SAIDA = RAIZ / "docs" / "loja" / "play" / "data-safety-em-dia.csv"
PROVAS = RAIZ / "docs" / "provas" / "play"

COL_Q = "Question ID (machine readable)"
COL_R = "Response ID (machine readable)"
COL_V = "Response value"

# ---------------------------------------------------------------- as respostas

# Perguntas gerais (sem opções: valor direto).
GERAIS = {
    "PSL_DATA_COLLECTION_COLLECTS_PERSONAL_DATA": "TRUE",
    # Tudo vai por HTTPS/TLS: Supabase (REST + Realtime) e Firebase.
    "PSL_DATA_COLLECTION_ENCRYPTED_IN_TRANSIT": "TRUE",
    # Mais → Definições → Apagar a conta (lib/screens/mais/definicoes_screen.dart).
    "PSL_DATA_COLLECTION_USER_REQUEST_DELETE": "TRUE",
    # Perguntas que só existem na exportação da consola (2026-09-06), não no
    # modelo público. A página tem a secção «Apagar a conta» com o caminho
    # dentro da app e o e-mail para quem já não consegue entrar.
    "PSL_ACCOUNT_DELETION_URL": "https://emdia.boraguarda.com/privacidade#apagar-conta",
    "PSL_DATA_DELETION_URL": "https://emdia.boraguarda.com/privacidade#apagar-conta",
    # Só se preenche quando o método de criação de conta é «outro»; não é.
    "PSL_ACM_SPECIFY": "",
    # PSL_HAS_OUTSIDE_APP_ACCOUNTS fica em branco: a API recusa-a com
    # «You cannot answer PSL_HAS_OUTSIDE_APP_ACCOUNTS» (2026-09-06).
    # Sem auditoria de segurança independente (MASA) — é honesto dizer que não.
    "PSL_INDEPENDENTLY_VALIDATED": "FALSE",
}

# Escolhas únicas ou múltiplas fora dos tipos de dados: TRUE só nas certas.
ESCOLHAS = {
    # Entra-se com e-mail + código de 6 números (Supabase OTP) ou com a conta
    # Google. Nunca há palavra-passe.
    "PSL_SUPPORTED_ACCOUNT_CREATION_METHODS": {"PSL_ACM_USER_ID_OTHER_AUTH", "PSL_ACM_OAUTH"},
    # Mais → Definições → Apagar a conta, e o e-mail na página de privacidade.
    "PSL_SUPPORT_DATA_DELETION_BY_USER": {"DATA_DELETION_YES"},
}

# Cada tipo recolhido: (obrigatório?, fins da recolha, porquê está aqui).
FUNCIONALIDADE = ["PSL_APP_FUNCTIONALITY"]
FUNC_E_CONTA = ["PSL_APP_FUNCTIONALITY", "PSL_ACCOUNT_MANAGEMENT"]

RECOLHIDOS = {
    "PSL_EMAIL": (True, FUNC_E_CONTA,
                  "entrar na app é por código enviado ao e-mail (auth.users.email)"),
    "PSL_USER_ACCOUNT": (True, FUNC_E_CONTA,
                         "o id de utilizador do Supabase liga o perfil aos dados"),
    "PSL_OTHER_PERSONAL": (False, FUNCIONALIDADE,
                           "matrícula e datas do carro, validade da carta, renovação "
                           "da residência e validade do certificado TVDE"),
    "PSL_OTHER": (True, FUNCIONALIDADE,
                  "rendimentos declarados e os valores de Segurança Social, IVA e IRS "
                  "que a app calcula, mais os custos do carro"),
    "PSL_PURCHASE_HISTORY": (False, FUNC_E_CONTA,
                             "assinatura pela Google Play (in_app_purchase está na app; "
                             "a tabela `assinaturas` guarda o estado)"),
    "PSL_PHOTOS": (False, FUNCIONALIDADE,
                   "fotos de comprovativos de pagamento e de extratos, escolhidas pelo "
                   "Photo Picker do Android"),
    "PSL_USER_GENERATED_CONTENT": (False, FUNCIONALIDADE,
                                   "as perguntas escritas ao assistente e as mensagens "
                                   "de suporte"),
    "PSL_DEVICE_ID": (False, FUNCIONALIDADE,
                      "o identificador do Firebase Messaging deste aparelho, para os "
                      "avisos dos prazos"),
}

# Nada é partilhado: Supabase e Firebase são fornecedores que tratam os dados por
# nossa conta, e a Google não conta isso como partilha.
PARTILHADOS: set[str] = set()

FORA = {
    "PSL_APPROX_LOCATION / PSL_PRECISE_LOCATION": "a app não pede localização nenhuma "
        "(foi a política de localização que travou o Bora — regra 9 do CLAUDE.md)",
    "PSL_NAME / PSL_PHONE": "as colunas existem na tabela mas nenhum ecrã as preenche",
    "PSL_CRASH_LOGS / PSL_PERFORMANCE_DIAGNOSTICS": "não há Crashlytics nem Analytics; "
        "só firebase_core e firebase_messaging",
    "PSL_CONTACTS / PSL_CALENDAR / PSL_AUDIO / PSL_SMS_CALL_LOG": "a app não lhes toca",
    "PSL_CREDIT_DEBIT_BANK_ACCOUNT_NUMBER": "o pagamento é da Google Play; a app nunca "
        "vê cartão nem IBAN",
}


# Sentinela: pergunta que este script não conhece — fica o valor que vier no
# modelo (numa exportação da consola isso é a resposta que já lá está).
MANTEM = object()


def valor(pergunta: str, resposta: str):
    """O que fica na coluna «Response value» de cada linha do CSV."""
    if pergunta in GERAIS:
        return GERAIS[pergunta]
    if pergunta in ESCOLHAS:
        return "TRUE" if resposta in ESCOLHAS[pergunta] else ""

    # Escolha dos tipos de dados: TRUE só nos que recolhemos.
    if pergunta.startswith("PSL_DATA_TYPES_"):
        return "TRUE" if resposta in RECOLHIDOS else ""

    if not pergunta.startswith("PSL_DATA_USAGE_RESPONSES:"):
        return MANTEM

    _, tipo, sub = pergunta.split(":", 2)
    if tipo not in RECOLHIDOS:
        return ""  # tipo não recolhido: fica tudo em branco
    obrigatorio, fins, _porque = RECOLHIDOS[tipo]

    if sub == "PSL_DATA_USAGE_COLLECTION_AND_SHARING":
        if resposta == "PSL_DATA_USAGE_ONLY_COLLECTED":
            return "TRUE"
        if resposta == "PSL_DATA_USAGE_ONLY_SHARED":
            return "TRUE" if tipo in PARTILHADOS else ""
        return ""
    if sub == "PSL_DATA_USAGE_EPHEMERAL":
        return "FALSE"  # fica guardado no servidor, não é só de passagem
    if sub == "DATA_USAGE_USER_CONTROL":
        alvo = ("PSL_DATA_USAGE_USER_CONTROL_REQUIRED" if obrigatorio
                else "PSL_DATA_USAGE_USER_CONTROL_OPTIONAL")
        return "TRUE" if resposta == alvo else ""
    if sub == "DATA_USAGE_COLLECTION_PURPOSE":
        return "TRUE" if resposta in fins else ""
    if sub == "DATA_USAGE_SHARING_PURPOSE":
        return ""  # não partilhamos nada
    return ""


def constroi(modelo: Path) -> tuple[str, list[str], list[str]]:
    linhas = list(csv.DictReader(io.open(modelo, encoding="utf-8-sig", newline="")))
    campos = list(linhas[0].keys())
    resumo, desconhecidas = [], []
    saida = io.StringIO(newline="")
    escritor = csv.DictWriter(saida, fieldnames=campos, lineterminator="\r\n")
    escritor.writeheader()
    for linha in linhas:
        v = valor(linha[COL_Q], linha[COL_R])
        if v is MANTEM:
            v = linha[COL_V]
            if linha[COL_Q] not in GERAIS:
                desconhecidas.append(f"{linha[COL_Q]}/{linha[COL_R] or '-'} (fica «{v or 'vazio'}»)")
        if v:
            etiqueta = " · ".join(linha["Human-friendly question label"].split("\n"))
            resumo.append(f"{v:5} | {linha[COL_Q]}{'/' + linha[COL_R] if linha[COL_R] else ''} | {etiqueta[:96]}")
        linha[COL_V] = v
        escritor.writerow(linha)
    return saida.getvalue(), resumo, desconhecidas


def main() -> int:
    if "--porque" in sys.argv:
        print("O QUE DECLARO QUE A APP RECOLHE (e porquê):\n")
        for tipo, (obrig, fins, porque) in RECOLHIDOS.items():
            print(f"  {tipo:28} {'obrigatório' if obrig else 'opcional   '}  {porque}")
        print("\nO QUE DECLARO QUE A APP NÃO RECOLHE:\n")
        for tipo, porque in FORA.items():
            print(f"  {tipo}\n      {porque}")
        print("\nPartilha com terceiros: NENHUMA. O Supabase e o Firebase tratam os")
        print("dados por conta do Em Dia — a Google não conta isso como partilha.")
        return 0

    modelo = MODELO
    if "--modelo" in sys.argv:
        modelo = Path(sys.argv[sys.argv.index("--modelo") + 1])
    if not modelo.exists():
        print(f"ERRO: não encontro o modelo {modelo}")
        return 1

    csv_texto, resumo, desconhecidas = constroi(modelo)
    SAIDA.write_text(csv_texto, encoding="utf-8", newline="")
    print(f"modelo: {modelo.name}")
    print(f"CSV escrito: {SAIDA.relative_to(RAIZ)} ({len(csv_texto)} bytes, "
          f"{len(resumo)} respostas preenchidas)")
    if desconhecidas:
        print(f"AVISO: {len(desconhecidas)} pergunta(s) que este script não conhece — "
              "ficam com o valor do modelo:")
        for d in desconhecidas[:12]:
            print("   ", d)

    PROVAS.mkdir(parents=True, exist_ok=True)
    agora = dt.datetime.now()
    prova = [f"# Prova — Segurança dos Dados da Play ({agora:%Y-%m-%d %H:%M})", "",
             f"Modo: **{'ENVIADO' if '--aplicar' in sys.argv else 'ENSAIO (não enviado)'}** · "
             f"modelo `{modelo.name}`",
             "", "## Respostas preenchidas", "", "```"] + resumo + ["```", ""]
    if desconhecidas:
        prova += ["## Perguntas que o script não conhece (ficam como vieram do modelo)", "",
                  "```"] + desconhecidas + ["```", ""]

    if "--aplicar" not in sys.argv:
        prova += ["> Ensaio. `python tool/play/data_safety.py --aplicar` envia para a Play."]
        (PROVAS / f"data-safety-{agora:%Y%m%d-%H%M%S}.md").write_text("\n".join(prova) + "\n", encoding="utf-8")
        print("ENSAIO — não enviei nada. Corre com --aplicar para enviar.")
        return 0

    p = Play()
    try:
        r = p._pedido("POST", f"{BASE}/{p.pacote}/dataSafety", {"safetyLabels": csv_texto})
        linha = f"`POST /applications/{p.pacote}/dataSafety` -> **HTTP 200** · resposta: `{r if r else '{}'}`"
        print("ENVIADO:", linha)
    except ErroPlay as e:
        linha = f"**ERRO**: {e}"
        print(linha)
        prova += ["## Resultado", "", linha]
        (PROVAS / f"data-safety-{agora:%Y%m%d-%H%M%S}.md").write_text("\n".join(prova) + "\n", encoding="utf-8")
        return 1
    prova += ["## Resultado", "", linha]
    (PROVAS / f"data-safety-{agora:%Y%m%d-%H%M%S}.md").write_text("\n".join(prova) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main())
