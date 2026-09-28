"""Mede o «movimento» de um mp4 com a mesma régua do fiscal_video.py do Bora.

fiscal_video.py: média do YAVG de tblend=all_mode=difference (luminância da
diferença entre fotogramas seguidos). O fiscal pede >= 12 (o reel mais parado
do Glovo deu 12,8).

    python tool/redes/medir_movimento.py saida.mp4
"""
import re
import shutil
import subprocess
import sys


def movimento(mp4: str) -> float:
    ff = shutil.which("ffmpeg")
    if not ff:
        import imageio_ffmpeg
        ff = imageio_ffmpeg.get_ffmpeg_exe()
    # A mesma cadeia do fiscal: 5 fotogramas por segundo, 320 de largura, e o
    # primeiro valor fora (diferença contra o nada).
    r = subprocess.run([ff, "-nostats", "-i", mp4, "-vf",
                        "fps=5,scale=320:-2,tblend=all_mode=difference,signalstats,"
                        "metadata=print:key=lavfi.signalstats.YAVG",
                        "-f", "null", "-"], capture_output=True, text=True)
    vals = [float(x) for x in re.findall(r"YAVG=([0-9.]+)", r.stderr)][1:]
    if not vals:
        raise SystemExit("sem medida: " + r.stderr[-300:])
    return round(sum(vals) / len(vals), 2)


if __name__ == "__main__":
    for f in sys.argv[1:]:
        print(f, movimento(f))
