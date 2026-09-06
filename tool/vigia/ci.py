# Vigia do CI: diz em que estado ficaram as ultimas corridas do GitHub Actions.
#
# Nao guarda token nenhum. Vai busca-lo ao gestor de credenciais do Windows,
# o mesmo que o `git push` usa (`git credential fill`) — assim nao ha mais uma
# chave em claro no disco, e quem correr isto ja tinha acesso ao repositorio.
#
#   python tool/vigia/ci.py            -> as 8 ultimas corridas
#   python tool/vigia/ci.py <sha>      -> so as desse commit, e sai com codigo
#                                          1 se alguma falhou, 2 se ainda corre
#
# Escrito a 2026-09-06 porque o `gh` nao esta instalado neste PC e a prova do
# bloco pede o estado do CI, nao a suposicao de que ficou verde.
import json
import subprocess
import sys
import urllib.request

REPO = "nilofulfarotuga-hue/em-dia-app"

# A consola deste PC e cp1252. Um nome de workflow com uma seta ("->" bonito)
# rebentava o print a meio da lista, e a corrida que faltava era logo a que
# interessava ver. Troca-se o que nao cabe em vez de deixar cair tudo.
try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass


def token() -> str:
    saida = subprocess.run(
        ["git", "credential", "fill"],
        input="protocol=https\nhost=github.com\n\n",
        capture_output=True, text=True, check=False,
    ).stdout
    for linha in saida.splitlines():
        if linha.startswith("password="):
            return linha[len("password="):]
    raise SystemExit("sem credencial do github guardada (faz um `git push` primeiro)")


def corridas(tok: str, limite: int = 8):
    pedido = urllib.request.Request(
        f"https://api.github.com/repos/{REPO}/actions/runs?per_page={limite}",
        headers={"Authorization": "token " + tok, "Accept": "application/vnd.github+json"},
    )
    return json.load(urllib.request.urlopen(pedido)).get("workflow_runs", [])


def main() -> int:
    sha = sys.argv[1] if len(sys.argv) > 1 else None
    linhas = corridas(token(), 20 if sha else 8)
    if sha:
        linhas = [r for r in linhas if r["head_sha"].startswith(sha)]
        if not linhas:
            print(f"nenhuma corrida para {sha}")
            return 2

    falhou = a_correr = 0
    for r in linhas:
        estado = r["conclusion"] or r["status"]
        if r["conclusion"] == "success":
            marca = "OK  "
        elif r["conclusion"] is None:
            marca = "... "
            a_correr += 1
        else:
            marca = "FALHOU"
            falhou += 1
        print(f'{marca} {r["head_sha"][:7]}  {r["name"]}  ({estado})  {r["created_at"]}')

    if falhou:
        print(f"\n{falhou} corrida(s) falharam")
        return 1
    if a_correr:
        print(f"\n{a_correr} ainda a correr")
        return 2
    print("\ntudo verde")
    return 0


if __name__ == "__main__":
    sys.exit(main())
