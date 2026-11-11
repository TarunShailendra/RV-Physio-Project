import math, subprocess, sys, os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

W, H, S, FPS = 1280, 720, 2, 30

def sc(pts): return [(x * S, y * S) for x, y in pts]
def circle(d, c, r, fill):
    x, y = c
    d.ellipse([(x - r) * S, (y - r) * S, (x + r) * S, (y + r) * S], fill=fill)
def poly(d, pts, fill): d.polygon(sc(pts), fill=fill)
def unit(a, b):
    dx, dy = b[0] - a[0], b[1] - a[1]; l = math.hypot(dx, dy) or 1
    return dx / l, dy / l
def capsule(d, a, b, ra, rb, fill):
    ux, uy = unit(a, b); nx, ny = -uy, ux
    poly(d, [(a[0] + nx * ra, a[1] + ny * ra), (b[0] + nx * rb, b[1] + ny * rb),
             (b[0] - nx * rb, b[1] - ny * rb), (a[0] - nx * ra, a[1] - ny * ra)], fill)
    circle(d, a, ra, fill); circle(d, b, rb, fill)

def font(sz, bold=True):
    for p in ["/usr/share/fonts/truetype/dejavu/DejaVuSans%s.ttf" % ("-Bold" if bold else ""),
              "/usr/share/fonts/dejavu/DejaVuSans%s.ttf" % ("-Bold" if bold else "")]:
        if os.path.exists(p): return ImageFont.truetype(p, sz * S)
    return ImageFont.load_default()

# ---------- colours ----------
SKIN, SKIN_D = (226, 174, 142), (196, 146, 116)
TOP = (236, 92, 110)
LEG, LEG_D = (62, 58, 110), (44, 41, 82)
HAIR = (62, 42, 34)
SHOE, SHOE_D = (246, 246, 250), (200, 200, 208)
MAT, MAT_SIDE = (58, 168, 158), (40, 128, 120)

# ---------- background (rendered once) ----------
def make_bg():
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
    circle(d, (700, 160), 40, (70, 74, 84)); circle(d, (700, 160), 35, (250, 250, 252))
    d.line(sc([(700, 160), (700, 136)]), fill=(50, 50, 60), width=3 * S)
    d.line(sc([(700, 160), (718, 170)]), fill=(50, 50, 60), width=3 * S)
    circle(d, (700, 160), 3, TOP)
    # exercise ball
    circle(d, (170, 506), 48, (140, 110, 190)); circle(d, (156, 490), 14, (166, 140, 212))
    # dumbbell rack
    for x in (1010, 1232):
        d.rectangle(sc([(x - 4, 380), (x + 4, 505)]), fill=(60, 64, 72))
    for sy, sz in ((412, 1.0), (462, 1.25)):
        d.rectangle(sc([(1000, sy + 22), (1242, sy + 28)]), fill=(60, 64, 72))
        for i in range(5):
            cx = 1030 + i * 44; r = (9 + i * 1.6) * sz
            d.rectangle(sc([(cx - 16, sy + 15), (cx + 16, sy + 19)]), fill=(150, 155, 165))
            for ox in (-14, 14):
                d.rounded_rectangle(sc([(cx + ox - 5, sy + 17 - r), (cx + ox + 5, sy + 17 + r)]),
                                    radius=3 * S, fill=(40, 42, 48))
    # kettlebells
    for kx, kr in ((1090, 20), (1150, 24)):
        d.arc(sc([(kx - 13, 532 - kr - 18), (kx + 13, 532 - kr + 8)]), 180, 360, fill=(40, 42, 48), width=6 * S)
        circle(d, (kx, 532), kr, (40, 42, 48))
    # mat with shadow
    d.ellipse(sc([(230, 592), (912, 610)]), fill=(40, 42, 48))
    d.rounded_rectangle(sc([(240, 584), (900, 598)]), radius=6 * S, fill=MAT_SIDE)
    d.rounded_rectangle(sc([(240, 584), (900, 590)]), radius=3 * S, fill=MAT)
    return bg

def blur_sprite(w, h, color, blur):
    sp = Image.new("RGBA", (w * S, h * S), color + (0,))
    a = Image.new("L", (w * S, h * S), 0)
    ImageDraw.Draw(a).ellipse([blur * S, blur * S, (w - blur) * S, (h - blur) * S], fill=255)
    sp.putalpha(a.filter(ImageFilter.GaussianBlur(blur * S / 2)))
    return sp
GLOW = blur_sprite(110, 90, (255, 120, 50), 18)
SHADOW = blur_sprite(150, 30, (20, 20, 25), 10)
def paste_sprite(img, sp, center, k):
    if k <= 0.01: return
    s = sp.copy(); s.putalpha(sp.split()[3].point(lambda v: int(v * k)))
    img.alpha_composite(s, (int(center[0] * S - s.width / 2), int(center[1] * S - s.height / 2)))

# ---------- kinematics ----------
SH = (430, 560); TORSO, THIGH, SHIN = 190, 170, 165
ANKLE = (800, 566); THETA_MAX = math.radians(24)

def knee_ik(hp, a_):
    dx, dy = a_[0] - hp[0], a_[1] - hp[1]
    dist = min(math.hypot(dx, dy), THIGH + SHIN - 0.01)
    base = math.atan2(dy, dx)
    al = math.acos((THIGH ** 2 + dist ** 2 - SHIN ** 2) / (2 * THIGH * dist))
    c = [(hp[0] + THIGH * math.cos(base + s * al), hp[1] + THIGH * math.sin(base + s * al)) for s in (-1, 1)]
    return min(c, key=lambda p: p[1])

def lerpw(table, f):
    for (f0, w0), (f1, w1) in zip(table, table[1:]):
        if f0 <= f <= f1: return w0 + (w1 - w0) * (f - f0) / (f1 - f0)
    return table[-1][1]
UPW = [(0, 25), (0.25, 30), (0.5, 22), (0.8, 24), (1, 27)]
DNW = [(0, 25), (0.3, 25), (0.6, 22), (1, 27)]
def torso_poly(hp, f0, f1, n=10):
    ux, uy = unit(SH, hp); nx, ny = uy, -ux  # n points "up"/belly side
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

# ---------- timeline ----------
INTRO, CYCLE, REPS, OUTRO = 0.8, 5.0, 3, 1.2
UP, HOLD, DOWN = 1.3, 1.5, 1.5
TOTAL = INTRO + CYCLE * REPS + OUTRO
ease = lambda x: 0.5 - 0.5 * math.cos(math.pi * max(0, min(1, x)))

def state(t):
    if t < INTRO: return 0, 1, "READY", "Lie on your back, knees bent, feet flat & hip-width apart", 0
    if t >= INTRO + CYCLE * REPS: return 0, REPS, "DONE", "Great work! 3 reps complete", 0
    tt = t - INTRO; rep = int(tt // CYCLE) + 1; c = tt % CYCLE
    if c < UP: return ease(c / UP), rep, "\u25B2 LIFT", "Press through your heels and lift your hips", 0
    c -= UP
    if c < HOLD: return 1, rep, "\u25CF HOLD", "Squeeze glutes: shoulders, hips & knees in one line", c / HOLD
    c -= HOLD
    if c < DOWN: return 1 - ease(c / DOWN), rep, "\u25BC LOWER", "Lower slowly with control", 0
    return 0, rep, "REST", "Reset and breathe", 0

F_TITLE, F_SUB, F_REP, F_PH, F_CUE = font(30), font(17, False), font(28), font(19), font(21)

def overlay(img, e, rep, phase, cue, hp, k, hold_p):
    ov = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(ov)
    # alignment guide
    a = max(0, min(1, (e - 0.85) / 0.15))
    if a > 0:
        ux, uy = unit(SH, k)
        p0 = (SH[0] - ux * 30, SH[1] - uy * 30); p1 = (k[0] + ux * 25, k[1] + uy * 25)
        L = math.hypot(p1[0] - p0[0], p1[1] - p0[1]); s = 0
        while s < L:
            s2 = min(L, s + 12)
            d.line(sc([(p0[0] + ux * s, p0[1] + uy * s), (p0[0] + ux * s2, p0[1] + uy * s2)]),
                   fill=(30, 200, 120, int(230 * a)), width=4 * S)
            s += 20
        for p in (SH, hp, k):
            circle(d, p, 7, (30, 200, 120, int(255 * a)))
    # panels
    d.rounded_rectangle(sc([(28, 26), (430, 108)]), radius=14 * S, fill=(255, 255, 255, 215))
    d.text(sc([(48, 36)])[0], "PELVIC BRIDGE", font=F_TITLE, fill=(40, 40, 56))
    d.text(sc([(50, 76)])[0], "Side view  \u00B7  Glutes \u00B7 Hamstrings \u00B7 Core", font=F_SUB, fill=(100, 100, 115))
    d.rounded_rectangle(sc([(1032, 26), (1252, 108)]), radius=14 * S, fill=(255, 255, 255, 215))
    d.text(sc([(1052, 34)])[0], "REP %d / %d" % (rep, REPS), font=F_REP, fill=(40, 40, 56))
    pc = {"\u25B2 LIFT": (236, 92, 110), "\u25CF HOLD": (30, 170, 105), "\u25BC LOWER": (70, 110, 200)}.get(phase, (110, 110, 125))
    d.text(sc([(1054, 72)])[0], phase, font=F_PH, fill=pc)
    if hold_p > 0:
        d.rounded_rectangle(sc([(1150, 80), (1232, 90)]), radius=5 * S, fill=(220, 224, 230, 255))
        d.rounded_rectangle(sc([(1150, 80), (1150 + 82 * hold_p, 90)]), radius=5 * S, fill=(30, 170, 105, 255))
    tw = d.textlength(cue, font=F_CUE) / S
    x0 = (W - tw) / 2
    d.rounded_rectangle(sc([(x0 - 22, 640), (x0 + tw + 22, 688)]), radius=24 * S, fill=(20, 22, 30, 200))
    d.text(sc([(x0, 650)])[0], cue, font=F_CUE, fill=(255, 255, 255))
    img.alpha_composite(ov)

def render(t, bg):
    e, rep, phase, cue, hp_ = state(t)
    img = bg.copy()
    th = THETA_MAX * e
    hpos = (SH[0] + TORSO * math.cos(th), SH[1] - TORSO * math.sin(th))
    paste_sprite(img, SHADOW, (hpos[0] - 20, 588), e * 0.55)
    hp, k = draw_figure(img, e)
    paste_sprite(img, GLOW, (hp[0] - 6, hp[1] + 6), e * 0.45)
    overlay(img, e, rep, phase, cue, hp, k, hp_)
    return img.convert("RGB").resize((W, H), Image.LANCZOS)

if __name__ == "__main__":
    bg = make_bg()
    if sys.argv[1] == "preview":
        for t in (0.3, 3.5):
            render(t, bg).save("preview_%s.png" % t)
    else:
        n = int(TOTAL * FPS)
        p = subprocess.Popen(["ffmpeg", "-y", "-loglevel", "error", "-f", "rawvideo", "-pix_fmt", "rgb24",
                              "-s", "%dx%d" % (W, H), "-r", str(FPS), "-i", "-", "-c:v", "libx264",
                              "-preset", "veryfast", "-crf", "20", "-pix_fmt", "yuv420p",
                              "-movflags", "+faststart", "pelvic_bridge_side_view.mp4"], stdin=subprocess.PIPE)
        for i in range(n):
            p.stdin.write(render(i / FPS, bg).tobytes())
        p.stdin.close(); p.wait()
        print("frames", n)
