"""Pelvic bridging: one text-free rep, drawn exactly as the owner's bridge.py.

Rest 0.4 s, lift 1.3 s, hold plateau 0.8 s, lower 1.5 s, rest 0.4 s.
"""
import math

from PIL import Image, ImageDraw

from spec import SideTiming, VideoSpec
from studio import (GLOW, H, HAIR, LEG, LEG_D, S, SHADOW, SHOE, SHOE_D, SKIN, SKIN_D, TOP, W,
                    capsule, circle, dashed_line, ease, paste_sprite, poly, sc, unit)

# ---------- kinematics (from bridge.py) ----------
SH = (430, 560)
TORSO, THIGH, SHIN = 190, 170, 165
ANKLE = (800, 566)
THETA_MAX = math.radians(24)


def knee_ik(hp, a_):
    dx, dy = a_[0] - hp[0], a_[1] - hp[1]
    dist = min(math.hypot(dx, dy), THIGH + SHIN - 0.01)
    base = math.atan2(dy, dx)
    al = math.acos((THIGH ** 2 + dist ** 2 - SHIN ** 2) / (2 * THIGH * dist))
    c = [(hp[0] + THIGH * math.cos(base + s * al), hp[1] + THIGH * math.sin(base + s * al)) for s in (-1, 1)]
    return min(c, key=lambda p: p[1])


def lerpw(table, f):
    for (f0, w0), (f1, w1) in zip(table, table[1:]):
        if f0 <= f <= f1:
            return w0 + (w1 - w0) * (f - f0) / (f1 - f0)
    return table[-1][1]


UPW = [(0, 25), (0.25, 30), (0.5, 22), (0.8, 24), (1, 27)]
DNW = [(0, 25), (0.3, 25), (0.6, 22), (1, 27)]


def torso_poly(hp, f0, f1, n=10):
    ux, uy = unit(SH, hp)
    nx, ny = uy, -ux  # n points "up"/belly side
    top, bot = [], []
    for i in range(n + 1):
        f = f0 + (f1 - f0) * i / n
        px, py = SH[0] + (hp[0] - SH[0]) * f, SH[1] + (hp[1] - SH[1]) * f
        top.append((px + nx * lerpw(UPW, f), py + ny * lerpw(UPW, f)))
        bot.append((px - nx * lerpw(DNW, f), py - ny * lerpw(DNW, f)))
    return top + bot[::-1]


def shoe(d, a_, fill, sole):
    x, y = a_[0] - 800, a_[1] - 566
    poly(d, [(788 + x, 558 + y), (810 + x, 555 + y), (826 + x, 566 + y), (850 + x, 574 + y),
             (855 + x, 584 + y), (784 + x, 584 + y)], fill)
    poly(d, [(783 + x, 581 + y), (856 + x, 581 + y), (856 + x, 587 + y), (783 + x, 587 + y)], sole)


def draw_leg(d, hp, a_, col, skin):
    k = knee_ik(hp, a_)
    capsule(d, hp, k, 23, 15, col)
    capsule(d, k, (a_[0] - 2, a_[1] - 4), 15, 9, col)
    return k


def draw_figure(img, e):
    th = THETA_MAX * e
    hp = (SH[0] + TORSO * math.cos(th), SH[1] - TORSO * math.sin(th))
    d = ImageDraw.Draw(img)
    # far leg
    fa = (ANKLE[0] - 14, ANKLE[1] - 2)
    draw_leg(d, (hp[0] + 3, hp[1] - 3), fa, LEG_D, SKIN_D)
    shoe(d, fa, SHOE_D, (190, 80, 95))
    # head & neck
    hc = (370, 559)
    capsule(d, (SH[0] - 12, SH[1]), (hc[0] + 16, hc[1] + 2), 11, 11, SKIN)
    circle(d, (hc[0] + 8, hc[1] - 27), 6, SKIN)  # nose
    circle(d, hc, 29, SKIN)
    d.pieslice([(hc[0] - 31) * S, (hc[1] - 31) * S, (hc[0] + 31) * S, (hc[1] + 31) * S], 70, 255, fill=HAIR)
    d.ellipse(sc([(hc[0] - 90, hc[1] + 7), (hc[0] - 20, hc[1] + 27)]), fill=HAIR)
    circle(d, (hc[0] - 24, hc[1] + 15), 5, TOP)
    d.ellipse(sc([(hc[0] - 2, hc[1] - 6), (hc[0] + 9, hc[1] + 8)]), fill=SKIN_D)  # ear
    # torso
    poly(d, torso_poly(hp, 0, 1), SKIN)
    circle(d, SH, 24, SKIN)
    poly(d, torso_poly(hp, 0.1, 0.6), TOP)
    poly(d, torso_poly(hp, 0.62, 1), LEG)
    poly(d, torso_poly(hp, 0.62, 0.67, 2), (90, 86, 150))  # waistband
    ux, uy = unit(SH, hp)
    circle(d, (hp[0] + uy * 4, hp[1] - ux * 4 + 4), 27, LEG)  # glutes
    # near leg + shoe
    k = draw_leg(d, hp, ANKLE, LEG, SKIN)
    shoe(d, ANKLE, SHOE, TOP)
    # near arm (flat on floor)
    capsule(d, (SH[0] + 4, SH[1] + 6), (518, 576), 11, 8, SKIN)
    capsule(d, (518, 576), (592, 578), 8, 7, SKIN)
    d.ellipse(sc([(588, 572), (612, 584)]), fill=SKIN)
    return hp, k


def draw_guide(img, e, hp, k):
    """Green dashed shoulder-hip-knee line, fading in over the top 15% of the lift."""
    a = max(0, min(1, (e - 0.85) / 0.15))
    if a <= 0:
        return
    ov = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(ov)
    ux, uy = unit(SH, k)
    p0 = (SH[0] - ux * 30, SH[1] - uy * 30)
    p1 = (k[0] + ux * 25, k[1] + uy * 25)
    dashed_line(d, [p0, SH, hp, k, p1], a)
    img.alpha_composite(ov)


def guide_bbox():
    """Pixel bounding box (x0, y0, x1, y1) of the alignment guide at full lift."""
    th = THETA_MAX
    hp = (SH[0] + TORSO * math.cos(th), SH[1] - TORSO * math.sin(th))
    k = knee_ik(hp, ANKLE)
    ux, uy = unit(SH, k)
    pts = [(SH[0] - ux * 30, SH[1] - uy * 30), (k[0] + ux * 25, k[1] + uy * 25), SH, hp, k]
    m = 12
    return (int(min(p[0] for p in pts) - m), int(min(p[1] for p in pts) - m),
            int(max(p[0] for p in pts) + m), int(max(p[1] for p in pts) + m))


# ---------- timeline: rest 0.4, lift 1.3, hold 0.8, lower 1.5, rest 0.4 ----------
REST, UP, HOLD, DOWN = 0.4, 1.3, 0.8, 1.5
DURATION = REST + UP + HOLD + DOWN + REST  # 4.4
TIMING = SideTiming(REST, REST + UP, REST + UP + HOLD, REST + UP + HOLD + DOWN)


def elevation(t):
    if t < TIMING.into_start:
        return 0.0
    if t < TIMING.hold:
        return ease((t - TIMING.into_start) / UP)
    if t < TIMING.out_start:
        return 1.0
    if t < TIMING.out_end:
        return 1 - ease((t - TIMING.out_start) / DOWN)
    return 0.0


def render_elevation(e, room):
    """The full-resolution RGB frame with the hips at elevation e (0..1)."""
    img = room.copy()
    th = THETA_MAX * e
    hpos = (SH[0] + TORSO * math.cos(th), SH[1] - TORSO * math.sin(th))
    paste_sprite(img, SHADOW, (hpos[0] - 20, 588), e * 0.55)
    hp, k = draw_figure(img, e)
    paste_sprite(img, GLOW, (hp[0] - 6, hp[1] + 6), e * 0.45)
    draw_guide(img, e, hp, k)
    return img.convert("RGB").resize((W, H), Image.LANCZOS)


def frame(t, room):
    return render_elevation(elevation(t), room)


VIDEOS = [
    VideoSpec(
        id="pelvic_bridging",
        exercise_key="pelvic_bridging",
        position="supine",
        duration=DURATION,
        sides=(TIMING,),
        props=frozenset(),
        frame=frame,
    ),
]
