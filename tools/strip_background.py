#!/usr/bin/env python3
"""Quita el fondo liso (blanco o de un color uniforme) de una capa de escenario.

Uso: python3 tools/strip_background.py entrada.png salida.png [tolerancia]

Rellena desde los bordes de la imagen todo lo que se parezca al color de las
esquinas (tolerancia por defecto 40) y lo vuelve transparente, con un borde
suavizado. Pensado para las capas "mid" y "near" generadas sobre fondo blanco.
"""
import sys
from collections import deque

from PIL import Image, ImageFilter


def strip(src: str, dst: str, tol: int = 40) -> None:
    img = Image.open(src).convert("RGBA")
    w, h = img.size
    px = img.load()
    corners = [px[0, 0], px[w - 1, 0], px[0, h - 1], px[w - 1, h - 1]]
    bg = tuple(sum(c[i] for c in corners) // 4 for i in range(3))

    def near(c):
        return sum(abs(c[i] - bg[i]) for i in range(3)) <= tol * 3

    mask = Image.new("L", (w, h), 255)
    m = mask.load()
    seen = bytearray(w * h)
    q = deque()
    for x in range(w):
        q.append((x, 0))
        q.append((x, h - 1))
    for y in range(h):
        q.append((0, y))
        q.append((w - 1, y))
    while q:
        x, y = q.popleft()
        i = y * w + x
        if seen[i]:
            continue
        seen[i] = 1
        if not near(px[x, y]):
            continue
        m[x, y] = 0
        if x > 0:
            q.append((x - 1, y))
        if x < w - 1:
            q.append((x + 1, y))
        if y > 0:
            q.append((x, y - 1))
        if y < h - 1:
            q.append((x, y + 1))
    mask = mask.filter(ImageFilter.GaussianBlur(1.2))
    img.putalpha(mask)
    img.save(dst)
    print(f"guardado: {dst}")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    strip(sys.argv[1], sys.argv[2], int(sys.argv[3]) if len(sys.argv) > 3 else 40)
