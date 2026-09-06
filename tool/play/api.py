#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Cliente mínimo da Google Play Android Publisher API v3 para o Em Dia.

Porquê existir: a Play Console é AngularDart e ignora eventos sintéticos — o
browser automatizado não consegue preencher a ficha nem carregar imagens de
forma fiável (cicatriz 2026-09-06). Pela API é determinístico e deixa prova.

Autenticação: chave da service account em C:\\BoraLocal\\_segredos\\em-dia\\
play-service-account.json (NUNCA no repo). JWT RS256 → OAuth2 → Bearer.

Uso como biblioteca:
    from api import Play
    p = Play()                       # ou Play(pacote='pt.emdia.app')
    with p.edicao() as ed:           # abre, e faz commit no fim (rollback em erro)
        p.listagem(ed, 'pt-PT', titulo=..., curta=..., completa=...)
        p.imagem(ed, 'pt-PT', 'icon', Path('docs/loja/play/icone-512.png'))
"""
from __future__ import annotations

import json
import mimetypes
import time
import urllib.error
import urllib.parse
import urllib.request
from contextlib import contextmanager
from pathlib import Path

CHAVE = Path(r"C:\BoraLocal\_segredos\em-dia\play-service-account.json")
PACOTE = "pt.emdia.app"
BASE = "https://androidpublisher.googleapis.com/androidpublisher/v3/applications"
BASE_UPLOAD = "https://androidpublisher.googleapis.com/upload/androidpublisher/v3/applications"


class ErroPlay(RuntimeError):
    """Erro da API com o corpo literal, para a prova não ser 'falhou'."""


class Play:
    def __init__(self, pacote: str = PACOTE, chave: Path = CHAVE):
        self.pacote = pacote
        self.sa = json.loads(chave.read_text(encoding="utf-8"))
        self._token = None
        self._expira = 0

    # ---------------- autenticação ----------------
    @property
    def token(self) -> str:
        if self._token and time.time() < self._expira - 60:
            return self._token
        import base64

        from cryptography.hazmat.primitives import hashes, serialization
        from cryptography.hazmat.primitives.asymmetric import padding

        def b64(d: bytes) -> bytes:
            return base64.urlsafe_b64encode(d).rstrip(b"=")

        agora = int(time.time())
        cab = b64(json.dumps({"alg": "RS256", "typ": "JWT"}).encode())
        corpo = b64(json.dumps({
            "iss": self.sa["client_email"],
            "scope": "https://www.googleapis.com/auth/androidpublisher",
            "aud": "https://oauth2.googleapis.com/token",
            "iat": agora, "exp": agora + 3600,
        }).encode())
        pk = serialization.load_pem_private_key(self.sa["private_key"].encode(), password=None)
        sig = b64(pk.sign(cab + b"." + corpo, padding.PKCS1v15(), hashes.SHA256()))
        jwt = (cab + b"." + corpo + b"." + sig).decode()
        dados = urllib.parse.urlencode({
            "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer", "assertion": jwt}).encode()
        r = json.loads(urllib.request.urlopen("https://oauth2.googleapis.com/token", data=dados, timeout=40).read())
        self._token, self._expira = r["access_token"], time.time() + int(r.get("expires_in", 3600))
        return self._token

    # ---------------- HTTP ----------------
    def _pedido(self, metodo: str, url: str, corpo=None, tipo="application/json"):
        dados = None
        if corpo is not None:
            dados = corpo if isinstance(corpo, bytes) else json.dumps(corpo).encode()
        req = urllib.request.Request(url, data=dados, method=metodo, headers={
            "Authorization": "Bearer " + self.token, "Content-Type": tipo})
        try:
            resposta = urllib.request.urlopen(req, timeout=180).read()
            return json.loads(resposta) if resposta else {}
        except urllib.error.HTTPError as e:
            raise ErroPlay(f"{metodo} {url.split('/v3/')[-1][:90]} -> HTTP {e.code}: {e.read().decode()[:400]}") from None

    # ---------------- edições ----------------
    def abre_edicao(self) -> str:
        return self._pedido("POST", f"{BASE}/{self.pacote}/edits", {})["id"]

    def valida(self, ed: str) -> dict:
        return self._pedido("POST", f"{BASE}/{self.pacote}/edits/{ed}:validate")

    def submete(self, ed: str) -> dict:
        return self._pedido("POST", f"{BASE}/{self.pacote}/edits/{ed}:commit")

    def descarta(self, ed: str) -> None:
        try:
            self._pedido("DELETE", f"{BASE}/{self.pacote}/edits/{ed}")
        except ErroPlay:
            pass

    @contextmanager
    def edicao(self, submeter: bool = True):
        ed = self.abre_edicao()
        print(f"  edição {ed} aberta")
        try:
            yield ed
        except Exception:
            self.descarta(ed)
            print(f"  edição {ed} descartada (erro)")
            raise
        if submeter:
            self.valida(ed)
            r = self.submete(ed)
            print(f"  edição {ed} submetida (commit ok: {r.get('id', ed)})")
        else:
            self.descarta(ed)
            print(f"  edição {ed} descartada (a pedido)")

    # ---------------- ficha da loja ----------------
    def listagem(self, ed: str, lingua: str, titulo: str, curta: str, completa: str, video: str | None = None) -> dict:
        corpo = {"language": lingua, "title": titulo, "shortDescription": curta, "fullDescription": completa}
        if video:
            corpo["video"] = video
        return self._pedido("PUT", f"{BASE}/{self.pacote}/edits/{ed}/listings/{lingua}", corpo)

    def listagens(self, ed: str) -> dict:
        return self._pedido("GET", f"{BASE}/{self.pacote}/edits/{ed}/listings")

    # ---------------- imagens ----------------
    # tipos: icon · featureGraphic · phoneScreenshots · sevenInchScreenshots ·
    #        tenInchScreenshots · tvBanner · tvScreenshots · wearScreenshots
    def imagens(self, ed: str, lingua: str, tipo: str) -> dict:
        return self._pedido("GET", f"{BASE}/{self.pacote}/edits/{ed}/listings/{lingua}/{tipo}")

    def apaga_imagens(self, ed: str, lingua: str, tipo: str) -> None:
        self._pedido("DELETE", f"{BASE}/{self.pacote}/edits/{ed}/listings/{lingua}/{tipo}")

    def imagem(self, ed: str, lingua: str, tipo: str, ficheiro: Path) -> dict:
        mime = mimetypes.guess_type(ficheiro.name)[0] or "image/png"
        url = f"{BASE_UPLOAD}/{self.pacote}/edits/{ed}/listings/{lingua}/{tipo}?uploadType=media"
        r = self._pedido("POST", url, ficheiro.read_bytes(), tipo=mime)
        return r

    # ---------------- pacotes e tracks ----------------
    def bundles(self, ed: str) -> dict:
        return self._pedido("GET", f"{BASE}/{self.pacote}/edits/{ed}/bundles")

    def sobe_bundle(self, ed: str, aab: Path) -> dict:
        url = f"{BASE_UPLOAD}/{self.pacote}/edits/{ed}/bundles?uploadType=media"
        return self._pedido("POST", url, aab.read_bytes(), tipo="application/octet-stream")

    def track(self, ed: str, nome: str) -> dict:
        return self._pedido("GET", f"{BASE}/{self.pacote}/edits/{ed}/tracks/{nome}")

    def poe_track(self, ed: str, nome: str, versoes: list[int], notas: dict[str, str], estado: str = "completed") -> dict:
        corpo = {"track": nome, "releases": [{
            "versionCodes": [str(v) for v in versoes],
            "status": estado,
            "releaseNotes": [{"language": l, "text": t} for l, t in notas.items()],
        }]}
        return self._pedido("PUT", f"{BASE}/{self.pacote}/edits/{ed}/tracks/{nome}", corpo)

    # ---------------- subscrições (dinheiro: só com "vai" do Danilo) ----------------
    def subscricoes(self) -> dict:
        return self._pedido("GET", f"{BASE}/{self.pacote}/subscriptions")

    def cria_subscricao(self, produto_id: str, corpo: dict) -> dict:
        url = (f"{BASE}/{self.pacote}/subscriptions"
               f"?productId={urllib.parse.quote(produto_id)}&regionsVersion.version=2022/02")
        return self._pedido("POST", url, corpo)


if __name__ == "__main__":
    p = Play()
    print("token OK;", "subscrições:", len(p.subscricoes().get("subscriptions", [])))
