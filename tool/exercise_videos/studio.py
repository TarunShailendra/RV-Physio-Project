"""Shared drawing kit for the exercise demonstration videos.

Everything here is lifted from the owner's reference script
(reference/bridge.py) without changing a coordinate or colour: the room,
sprites, primitives and easing. Exercises draw their figure on top of
make_room() and are encoded by encode().
"""
import math
import subprocess
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFilter

W, H, S, FPS = 1280, 720, 2, 30


def sc(pts):
    return [(x * S, y * S) for x, y in pts]


def circle(d, c, r, fill):
    x, y = c
    d.ellipse([(x - r) * S, (y - r) * S, (x + r) * S, (y + r) * S], fill=fill)


def poly(d, pts, fill):
    d.polygon(sc(pts), fill=fill)


def unit(a, b):
    dx, dy = b[0] - a[0], b[1] - a[1]
    l = math.hypot(dx, dy) or 1
    return dx / l, dy / l


def capsule(d, a, b, ra, rb, fill):
    ux, uy = unit(a, b)
    nx, ny = -uy, ux
    poly(d, [(a[0] + nx * ra, a[1] + ny * ra), (b[0] + nx * rb, b[1] + ny * rb),
             (b[0] - nx * rb, b[1] - ny * rb), (a[0] - nx * ra, a[1] - ny * ra)], fill)
    circle(d, a, ra, fill)
    circle(d, b, rb, fill)


def ease(x):
    return 0.5 - 0.5 * math.cos(math.pi * max(0, min(1, x)))


# ---------- colours ----------
SKIN, SKIN_D = (226, 174, 142), (196, 146, 116)
TOP = (236, 92, 110)
LEG, LEG_D = (62, 58, 110), (44, 41, 82)
HAIR = (62, 42, 34)
SHOE, SHOE_D = (246, 246, 250), (200, 200, 208)
MAT, MAT_SIDE = (58, 168, 158), (40, 128, 120)


# ---------- room (rendered once per prop set) ----------
def make_room(props: frozenset = frozenset()) -> Image.Image:
    """The supersampled RGBA room. props may contain "wall" and "chair"."""
    bg = Image.new("RGBA", (W * S, H * S))
    d = ImageDraw.Draw(bg)
    for y in range(500):  # wall gradient
        t = y / 500
        c = tuple(int(a + (b - a) * t) for a, b in zip((236, 239, 243), (212, 218, 227)))
        d.rectangle([0, y * S, W * S, (y + 1) * S], fill=c)
    for y in range(500, H):  # floor
        t = (y - 500) / 220
        c = tuple(int(a + (b - a) * t) for a, b in zip((84, 88, 98), (52, 55, 63)))
        d.rectangle([0, y * S, W * S, (y + 1) * S], fill=c)
    for yy in (530, 570, 625, 690):
        d.line(sc([(0, yy), (W, yy)]), fill=(96, 100, 110), width=S)
    d.rectangle(sc([(0, 330), (W, 344)]), fill=(120, 190, 182))       # wall stripe
    d.rectangle(sc([(0, 492), (W, 502)]), fill=(186, 192, 200))       # baseboard
    # window
    d.rectangle(sc([(84, 84), (336, 296)]), fill=(196, 202, 210))
    for y in range(94, 286):
        t = (y - 94) / 192
        c = tuple(int(a + (b - a) * t) for a, b in zip((176, 214, 240), (222, 238, 248)))
        d.rectangle(sc([(94, y), (326, y + 1)]), fill=c)
    d.rectangle(sc([(206, 94), (214, 286)]), fill=(196, 202, 210))
    d.rectangle(sc([(94, 186), (326, 194)]), fill=(196, 202, 210))
    # wall clock
    circle(d, (700, 160), 40, (70, 74, 84))
    circle(d, (700, 160), 35, (250, 250, 252))
    d.line(sc([(700, 160), (700, 136)]), fill=(50, 50, 60), width=3 * S)
    d.line(sc([(700, 160), (718, 170)]), fill=(50, 50, 60), width=3 * S)
    circle(d, (700, 160), 3, TOP)
    # exercise ball
    circle(d, (170, 506), 48, (140, 110, 190))
    circle(d, (156, 490), 14, (166, 140, 212))
    # dumbbell rack and kettlebells (the wall prop stands where they are)
    rack = "wall" not in props
    for x in (1010, 1232) if rack else ():
        d.rectangle(sc([(x - 4, 380), (x + 4, 505)]), fill=(60, 64, 72))
    for sy, sz in ((412, 1.0), (462, 1.25)) if rack else ():
        d.rectangle(sc([(1000, sy + 22), (1242, sy + 28)]), fill=(60, 64, 72))
        for i in range(5):
            cx = 1030 + i * 44
            r = (9 + i * 1.6) * sz
            d.rectangle(sc([(cx - 16, sy + 15), (cx + 16, sy + 19)]), fill=(150, 155, 165))
            for ox in (-14, 14):
                d.rounded_rectangle(sc([(cx + ox - 5, sy + 17 - r), (cx + ox + 5, sy + 17 + r)]),
                                    radius=3 * S, fill=(40, 42, 48))
    for kx, kr in ((1090, 20), (1150, 24)) if rack else ():
        d.arc(sc([(kx - 13, 532 - kr - 18), (kx + 13, 532 - kr + 8)]), 180, 360, fill=(40, 42, 48), width=6 * S)
        circle(d, (kx, 532), kr, (40, 42, 48))
    # mat with shadow
    d.ellipse(sc([(230, 592), (912, 610)]), fill=(40, 42, 48))
    d.rounded_rectangle(sc([(240, 584), (900, 598)]), radius=6 * S, fill=MAT_SIDE)
    d.rounded_rectangle(sc([(240, 584), (900, 590)]), radius=3 * S, fill=MAT)
    if "wall" in props:
        _draw_wall(d)
    if "chair" in props:
        _draw_chair(d)
    return bg


def _draw_wall(d):
    """A plain wall panel to stand against, right of the mat, in the room's palette."""
    # make_room leaves the rack out when this prop is present.
    d.rectangle(sc([(930, 0), (W, 500)]), fill=(228, 232, 238))
    d.rectangle(sc([(930, 0), (940, 500)]), fill=(196, 202, 210))      # panel edge
    d.rectangle(sc([(930, 330), (W, 344)]), fill=(120, 190, 182))      # wall stripe continues
    d.rectangle(sc([(930, 492), (W, 502)]), fill=(186, 192, 200))      # baseboard


def _draw_chair(d):
    """A side-on chair to hold, facing right, in the room's palette."""
    wood, wood_d = (176, 142, 108), (140, 108, 80)
    d.rectangle(sc([(584, 330), (600, 596)]), fill=wood_d)             # back post and rear leg
    d.rounded_rectangle(sc([(576, 326), (606, 372)]), radius=6 * S, fill=wood)   # backrest
    d.rectangle(sc([(700, 470), (714, 596)]), fill=wood_d)             # front leg
    d.rectangle(sc([(600, 520), (714, 528)]), fill=wood_d)             # rung
    d.rounded_rectangle(sc([(576, 440), (722, 462)]), radius=6 * S, fill=wood)   # seat


def blur_sprite(w, h, color, blur):
    sp = Image.new("RGBA", (w * S, h * S), color + (0,))
    a = Image.new("L", (w * S, h * S), 0)
    ImageDraw.Draw(a).ellipse([blur * S, blur * S, (w - blur) * S, (h - blur) * S], fill=255)
    sp.putalpha(a.filter(ImageFilter.GaussianBlur(blur * S / 2)))
    return sp


GLOW = blur_sprite(110, 90, (255, 120, 50), 18)
SHADOW = blur_sprite(150, 30, (20, 20, 25), 10)


def paste_sprite(img, sp, center, k):
    if k <= 0.01:
        return
    s = sp.copy()
    s.putalpha(sp.split()[3].point(lambda v: int(v * k)))
    img.alpha_composite(s, (int(center[0] * S - s.width / 2), int(center[1] * S - s.height / 2)))


def dashed_line(d, points, alpha, color=(30, 200, 120), dash=12, gap=20, width=4):
    """Green dashed alignment guide from points[0] to points[-1], with a dot on
    each interior point. alpha is 0..1; d draws on an RGBA overlay."""
    p0, p1 = points[0], points[-1]
    ux, uy = unit(p0, p1)
    length = math.hypot(p1[0] - p0[0], p1[1] - p0[1])
    s = 0
    while s < length:
        s2 = min(length, s + dash)
        d.line(sc([(p0[0] + ux * s, p0[1] + uy * s), (p0[0] + ux * s2, p0[1] + uy * s2)]),
               fill=color + (int(230 * alpha),), width=width * S)
        s += gap
    for p in points[1:-1]:
        circle(d, p, 7, color + (int(255 * alpha),))


def encode(frames: Iterable[Image.Image], path: Path) -> int:
    """H.264 / yuv420p / faststart / crf 20 via the bundled ffmpeg. Returns frames written."""
    import imageio_ffmpeg

    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    p = subprocess.Popen(
        [imageio_ffmpeg.get_ffmpeg_exe(), "-y", "-loglevel", "error", "-f", "rawvideo",
         "-pix_fmt", "rgb24", "-s", "%dx%d" % (W, H), "-r", str(FPS), "-i", "-",
         "-c:v", "libx264", "-preset", "veryfast", "-crf", "20", "-pix_fmt", "yuv420p",
         "-movflags", "+faststart", str(path)],
        stdin=subprocess.PIPE)
    n = 0
    try:
        for fr in frames:
            p.stdin.write(fr.tobytes())
            n += 1
    finally:
        p.stdin.close()
        rc = p.wait()
    if rc != 0:
        raise RuntimeError("ffmpeg exited with %d" % rc)
    return n
