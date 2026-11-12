"""The same woman seen from the front: lying on her side, or on her back from her feet.

    python tool/exercise_videos/figure_front.py --poses

writes build/exercise_videos/poses_front.png: lying on her side with the knees
bent, and with the legs long; lying on her back seen from the feet, at rest
and with the knees lowered to one side.

figure.py draws her in the picture plane; these views need depth, so here she
is posed with 3D points and projected. Coordinates are pixels at full size:
x to the right of the picture, y up, z toward the camera; the mat's surface is
y = 0. A Camera looks down at the mat from `elevation` degrees, in
perspective when it has a `distance`.

Everything that makes her the same person comes from figure.py and studio.py:
the palette, torso length, thigh and shin, arm reach, limb radii, head and
hair radii, the hair tie, and the shoe's profile (given a width here). Limbs
are capsules, as there; the trunk is a tube of elliptical sections whose depth
is figure.py's torso profile and whose width is set below.

Poses are plain data (Body: a Trunk, a Head and named Limbs), painted in the
order the Body lists, back to front. The exercise modules build them with the
helpers here: side_lying() and supine() give the trunk, head and arms of each
view, and leg() places a leg by its hip, ankle and the way the knee points.
"""
import math
import sys
from dataclasses import dataclass, field
from pathlib import Path

from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

from figure import (_FORE, _HAND_R, _SHOE, _SOLE, _TIE, _UPPER, DNW, FAR_SOLE, SHIN,  # noqa: E402
                    THIGH, TORSO, UPW, WAISTBAND, _lerpw)
from studio import (GLOW, HAIR, LEG, LEG_D, MAT, MAT_SIDE, SHADOW, SHOE, SHOE_D, SKIN,  # noqa: E402
                    SKIN_D, TOP, H, S, W, capsule, circle, dashed_line, paste_sprite)

Vec = tuple[float, float, float]

UPPER_ARM = math.hypot(*_UPPER)     # shoulder -> elbow, figure.py's (with its ARM_REACH)
FOREARM = math.hypot(*_FORE)        # elbow -> wrist
HEAD_R, HAIR_R = 29, 31             # figure.py's head and hair radii
NECK = 60                           # shoulder -> head centre along the spine (figure.py's _HEAD)
SHOE_HALF_WIDTH = 12
# Half the trunk's width across the body, shoulders (0) to hips (1) and on
# between the thighs; its depth is figure.py's torso profile (UPW and DNW).
ACROSS_W = [(0, 40), (0.12, 40), (0.45, 30), (0.62, 31), (0.85, 38), (1.0, 39), (1.12, 26)]
ARM_ROOT = 32                       # spine -> top of each upper arm, across the shoulders
HIP_HALF = 18                       # spine -> each hip joint


# ---------- 3D vectors ----------
def add(a, b):
    return (a[0] + b[0], a[1] + b[1], a[2] + b[2])


def sub(a, b):
    return (a[0] - b[0], a[1] - b[1], a[2] - b[2])


def mul(a, k):
    return (a[0] * k, a[1] * k, a[2] * k)


def dot(a, b):
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]


def cross(a, b):
    return (a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0])


def norm(a):
    return math.sqrt(dot(a, a))


def unit3(a):
    n = norm(a) or 1.0
    return mul(a, 1 / n)


def lerp3(a, b, k):
    return add(a, mul(sub(b, a), k))


def rotate(v, axis, deg):
    """v turned deg degrees about the unit vector axis (right-handed)."""
    r = math.radians(deg)
    c, s = math.cos(r), math.sin(r)
    return add(add(mul(v, c), mul(cross(axis, v), s)), mul(axis, dot(axis, v) * (1 - c)))


def two_bone(root, end, l1, l2, pole):
    """Middle joint of root-(l1)-?-(l2)-end, bent toward the direction pole."""
    d = sub(end, root)
    dist = max(1e-6, min(norm(d), l1 + l2 - 0.01))
    u = unit3(d)
    n = unit3(sub(pole, mul(u, dot(pole, u))))
    ca = max(-1.0, min(1.0, (l1 ** 2 + dist ** 2 - l2 ** 2) / (2 * l1 * dist)))
    return add(root, add(mul(u, l1 * ca), mul(n, l1 * math.sqrt(1 - ca * ca))))


# ---------- camera ----------
@dataclass(frozen=True)
class Camera:
    """origin: where the 3D origin lands on screen. elevation: degrees the
    camera looks down. distance: px from the origin to the camera, for
    perspective (None: parallel projection). scale: px per unit at the origin.
    yaw: degrees the camera has walked round to the picture's right, about
    the vertical through the origin."""
    origin: tuple[float, float]
    elevation: float
    distance: float | None = None
    scale: float = 1.0
    yaw: float = 0.0

    def _view(self, p):
        x, y, z = p
        if self.yaw:
            w = math.radians(self.yaw)
            x, z = x * math.cos(w) - z * math.sin(w), x * math.sin(w) + z * math.cos(w)
        e = math.radians(self.elevation)
        c, s = math.cos(e), math.sin(e)
        return x, y * c - z * s, y * s + z * c

    def toward(self) -> Vec:
        """Unit vector from the scene toward the camera."""
        e, w = math.radians(self.elevation), math.radians(self.yaw)
        return (math.cos(e) * math.sin(w), math.sin(e), math.cos(e) * math.cos(w))

    def depth(self, p) -> float:
        """Distance toward the camera: larger is nearer."""
        return self._view(p)[2]

    def k(self, p) -> float:
        """Screen pixels per unit at p."""
        if self.distance is None:
            return self.scale
        return self.scale * self.distance / (self.distance - self._view(p)[2])

    def __call__(self, p) -> tuple[float, float]:
        x, y, _ = self._view(p)
        k = self.k(p)
        return (self.origin[0] + x * k, self.origin[1] - y * k)


# ---------- the pose ----------
@dataclass(frozen=True)
class Limb:
    """An arm (shoulder root, elbow, wrist) or a leg (hip, knee, ankle).
    toward: the hand's or the toes' direction. up: a leg's foot, from the sole
    to the top of the foot. shade: 0 lit .. 1 in shadow (figure.py's far
    limb colours); upper_shade and foot_shade, if given, shade the upper arm
    or thigh, and the shoe, apart from the rest. kneecap: see below."""
    root: Vec
    mid: Vec
    end: Vec
    toward: Vec
    up: Vec = (0.0, 0.0, 0.0)
    shade: float = 0.0
    upper_shade: float | None = None
    foot_shade: float | None = None
    kneecap: float = 0.0       # a leg's kneecap radius, drawn lighter on the shin's top; 0: none

    def upper(self):
        return self.shade if self.upper_shade is None else self.upper_shade

    def foot(self):
        return self.shade if self.foot_shade is None else self.foot_shade


@dataclass(frozen=True)
class Trunk:
    """shoulder and pelvis: points on the spine (pelvis = between the hip
    joints). across: unit, the body's side-to-side. front: unit, toward the
    belly. roll: degrees the pelvis turns about the spine, fading out toward
    the ribs (right-handed about pelvis -> shoulder). seat_shade: 0..1 shade
    on the leggings, as under raised thighs."""
    shoulder: Vec
    pelvis: Vec
    across: Vec
    front: Vec
    roll: float = 0.0
    seat_shade: float = 0.0

    def at(self, f):
        """Spine point and section axes (across, front) at f: 0 shoulders .. 1 hips."""
        c = lerp3(self.shoulder, self.pelvis, f)
        a, b = self.across, self.front
        turn = self.roll * _smooth((f - 0.4) / 0.45)
        if turn:
            ax = unit3(sub(self.shoulder, self.pelvis))
            a, b = rotate(a, ax, turn), rotate(b, ax, turn)
        return c, a, b

    def surface(self, f, side=0.0):
        """Point on the front of the trunk at f; side -1..1 moves it across."""
        c, a, b = self.at(f)
        return add(add(c, mul(b, _depth(f) * math.sqrt(max(0.0, 1 - side * side)))),
                   mul(a, _lerpw(ACROSS_W, f) * side))


@dataclass(frozen=True)
class Head:
    centre: Vec
    face: Vec      # unit, the way the face looks
    crown: Vec     # unit, toward the top of the head
    neck: Vec      # where the neck meets the trunk


@dataclass(frozen=True)
class Body:
    trunk: Trunk
    head: Head
    arms: dict = field(default_factory=dict)    # name -> Limb
    legs: dict = field(default_factory=dict)    # name -> Limb
    # paint order, back to front: "trunk", "head", "arm <name>", "leg <name>",
    # or a leg in two parts, "thigh <name>" and "shin <name>" (with the shoe);
    # "glow" pastes the glow there (otherwise it goes on top of everything);
    # "shadow" lays soft shadows on the mat under the knees
    layers: tuple = ()


def _smooth(x):
    x = max(0.0, min(1.0, x))
    return x * x * (3 - 2 * x)


def _depth(f):
    """Half the trunk's depth at f: figure.py's front and back half-widths."""
    return (_lerpw(UPW, f) + _lerpw(DNW, f)) / 2


def leg(hip, ankle, pole, toes, shade=0.0, upper_shade=None, foot_up=None,
        foot_shade=None, kneecap=0.0) -> Limb:
    """A leg from hip to ankle, the knee bent toward pole, the toes pointing
    along `toes` (at right angles to the shin is figure.py's flat foot). The
    top of the foot faces the knee, or foot_up if given (a planted foot)."""
    knee = two_bone(hip, ankle, THIGH, SHIN, pole)
    f = unit3(toes)
    up = foot_up or sub(knee, ankle)
    return Limb(hip, knee, ankle, f, unit3(sub(up, mul(f, dot(up, f)))), shade, upper_shade,
                foot_shade, kneecap)


def arm(root, hand, pole, toward, shade=0.0) -> Limb:
    """An arm from its shoulder root with the middle of the hand at `hand`,
    the elbow bent toward pole (a straight arm if it cannot reach)."""
    wrist = sub(hand, mul(toward, _HAND_R[0] - 4))
    elbow = two_bone(root, wrist, UPPER_ARM, FOREARM, pole)
    return Limb(root, elbow, wrist, toward, shade=shade)


def straight_arm(root, direction, shade=0.0, toward=None) -> Limb:
    d = unit3(direction)
    elbow = add(root, mul(d, UPPER_ARM))
    return Limb(root, elbow, add(elbow, mul(d, FOREARM)), toward or d, shade=shade)


# ---------- drawing ----------
def _mix(a, b, k):
    return tuple(round(x + (y - x) * k) for x, y in zip(a, b))


def _hull(pts):
    """Convex hull of 2D points (monotone chain)."""
    pts = sorted(set(pts))
    if len(pts) < 3:
        return pts

    def half(seq):
        out = []
        for p in seq:
            while len(out) >= 2 and ((out[-1][0] - out[-2][0]) * (p[1] - out[-2][1])
                                     - (out[-1][1] - out[-2][1]) * (p[0] - out[-2][0])) <= 0:
                out.pop()
            out.append(p)
        return out

    lo, hi = half(pts), half(pts[::-1])
    return lo[:-1] + hi[:-1]


class _Pen:
    def __init__(self, img, cam):
        self.d, self.cam = ImageDraw.Draw(img), cam

    def capsule(self, a, b, ra, rb, fill):
        cam = self.cam
        capsule(self.d, cam(a), cam(b), ra * cam.k(a), rb * cam.k(b), fill)

    def circle(self, c, r, fill):
        circle(self.d, self.cam(c), r * self.cam.k(c), fill)

    def solid(self, pts, fill):
        """The convex hull of the projected points."""
        self.d.polygon([(x * S, y * S) for x, y in _hull([self.cam(p) for p in pts])], fill=fill)

    def tube(self, sections, fill):
        """A trunk-like tube through elliptical sections (centre, a, b): its
        outline is each section's extremes either side of the projected spine."""
        cam = self.cam
        left, right = [], []
        n = len(sections)
        for i, (c, a, b) in enumerate(sections):
            p0, p1 = cam(sections[max(0, i - 1)][0]), cam(sections[min(n - 1, i + 1)][0])
            dx, dy = p1[0] - p0[0], p1[1] - p0[1]
            nx, ny = -dy, dx
            ring = [cam(add(c, add(mul(a, math.cos(t)), mul(b, math.sin(t)))))
                    for t in (2 * math.pi * j / 24 for j in range(24))]
            key = lambda q: q[0] * nx + q[1] * ny          # noqa: E731
            left.append(max(ring, key=key))
            right.append(min(ring, key=key))
        self.d.polygon([(x * S, y * S) for x, y in left + right[::-1]], fill=fill)


def _trunk_sections(trunk, f0, f1, n):
    out = []
    for i in range(n + 1):
        f = f0 + (f1 - f0) * i / n
        c, a, b = trunk.at(f)
        out.append((c, mul(a, _lerpw(ACROSS_W, f)), mul(b, _depth(f))))
    return out


def _draw_trunk(pen, trunk):
    sh_c, sh_a, _ = trunk.at(0.04)
    hp_c, hp_a, _ = trunk.at(1.0)
    pen.tube(_trunk_sections(trunk, 0, 1.12, 28), SKIN)
    for side in (-1, 1):                                   # the shoulders' round
        pen.circle(add(sh_c, mul(sh_a, side * (ARM_ROOT - 6))), 12, SKIN)
    pen.tube(_trunk_sections(trunk, 0.1, 0.6, 12), TOP)
    seat = _mix(LEG, LEG_D, trunk.seat_shade)
    pen.tube(_trunk_sections(trunk, 0.62, 1.12, 12), seat)
    for side in (-1, 1):                                   # the hips' round
        pen.circle(add(hp_c, mul(hp_a, side * HIP_HALF)), 24, seat)
    pen.tube(_trunk_sections(trunk, 0.62, 0.67, 2), WAISTBAND)


def _draw_head(pen, head):
    c, f, u = head.centre, head.face, head.crown
    e = unit3(cross(f, u))
    pen.capsule(head.neck, add(c, mul(u, -16)), 11, 11, SKIN)
    # the bun's tie at the crown, behind the head, and the ponytail lying
    # beyond it on whatever is under the back of the head
    tie = add(add(c, mul(u, HAIR_R - 2)), mul(f, -_TIE[1]))
    pen.capsule(add(tie, mul(u, 4)), add(add(tie, mul(u, 40)), mul(f, -6)), 9, 11, HAIR)
    pen.circle(tie, 5, TOP)
    # The hair is a disc behind the face; the face, a slightly smaller disc
    # moved toward the chin on screen, leaves the hairline as a crescent at
    # the crown, wider the more the face turns from the camera.
    cam = pen.cam
    cs, k = cam(c), cam.k(c)
    up2 = cam(add(c, u))
    cu = (up2[0] - cs[0], up2[1] - cs[1])
    n = math.hypot(*cu) or 1.0
    cu = (cu[0] / n, cu[1] / n)
    turned = 1 - abs(dot(f, cam.toward()))
    shift = (7 + 7 * turned) * k
    circle(pen.d, cs, HAIR_R * k, HAIR)
    for side in (-1, 1):                    # ears, at the sides of the face
        ear = add(add(c, mul(e, side * (HEAD_R - 1))), mul(u, -5))
        pen.capsule(add(ear, mul(u, -3)), add(ear, mul(u, 3)), 4.5, 4.5, SKIN_D)
    circle(pen.d, (cs[0] - cu[0] * shift, cs[1] - cu[1] * shift), (HEAD_R - 3) * k, SKIN)
    if turned < 0.2:                        # a nose only on a face turned to the camera
        nose = add(add(c, mul(u, -9)), mul(f, HEAD_R - 4))
        pen.capsule(add(nose, mul(u, 3)), add(nose, mul(u, -3)), 3.5, 4.5, SKIN_D)


def _draw_arm(pen, a: Limb):
    col = _mix(SKIN, SKIN_D, a.shade)
    pen.capsule(a.root, a.mid, 11, 8, _mix(SKIN, SKIN_D, a.upper()))
    pen.capsule(a.mid, a.end, 8, 7, col)
    pen.capsule(add(a.end, mul(a.toward, 2)), add(a.end, mul(a.toward, 14)), _HAND_R[1], _HAND_R[1], col)


# the shoe's half-width along its length (figure.py's profile x): a rounded
# footprint, narrow at the heel and the toe
_SHOE_W = [(-17, 7), (-8, 10), (10, 11), (36, SHOE_HALF_WIDTH), (50, 10), (56, 6)]


def _shoe_points(ankle, f, u, prof):
    s = unit3(cross(f, u))
    out = []
    for x, y in prof:
        p = add(ankle, add(mul(f, x), mul(u, -y)))
        w = _lerpw(_SHOE_W, x)
        out += [add(p, mul(s, w)), add(p, mul(s, -w))]
    return out


def _draw_leg(pen, g: Limb, part="leg"):
    """part: "leg" (all of it), "thigh", or "shin" (with the shoe)."""
    if part != "shin":
        pen.capsule(g.root, g.mid, 23, 15, _mix(LEG, LEG_D, g.upper()))
    if part == "thigh":
        return
    pen.capsule(g.mid, add(g.end, mul(g.up, 4)), 15, 9, _mix(LEG, LEG_D, g.shade))
    # figure.py's shoe profile, given a width: the sole under the upper
    (x0, y0), (x1, _), (_, y1) = _SOLE[0], _SOLE[1], _SOLE[2]
    sole = [(x0 + (x1 - x0) * i / 12, y) for i in range(13) for y in (y0, y1)]
    pen.solid(_shoe_points(g.end, g.toward, g.up, sole), _mix(TOP, FAR_SOLE, g.foot()))
    upper = [(x, min(y, 15)) for x, y in _dense(_SHOE)]
    pen.solid(_shoe_points(g.end, g.toward, g.up, upper), _mix(SHOE, SHOE_D, g.foot()))
    if g.kneecap:
        # a kneecap catching the light: the leggings, a little lighter
        pen.circle(g.mid, g.kneecap, _mix(_mix(LEG, WAISTBAND, KNEE_LIGHT), LEG_D, g.shade))



def _dense(poly, step=6.0):
    """The closed polygon with points added every `step` along its edges."""
    out = []
    for a, b in zip(poly, poly[1:] + poly[:1]):
        n = max(1, math.ceil(math.dist(a, b) / step))
        out += [(a[0] + (b[0] - a[0]) * i / n, a[1] + (b[1] - a[1]) * i / n) for i in range(n)]
    return out


def draw_front_figure(img: Image.Image, body: Body, cam: Camera, *, glow_at: Vec | None = None,
                      glow_k: float = 0.0) -> None:
    """Draw body on the supersampled RGBA image img, painting body.layers in
    order; the orange glow sits at the 3D point glow_at at strength glow_k,
    pasted at the "glow" layer if there is one, else over everything."""
    pen = _Pen(img, cam)

    def glow():
        if glow_at is not None:
            paste_sprite(img, GLOW, cam(glow_at), glow_k)

    for layer in body.layers:
        kind, _, name = layer.partition(" ")
        if kind == "glow":
            glow()
            pen = _Pen(img, cam)
        elif kind == "shadow":              # soft shadows on the mat under the knees
            for g in body.legs.values():
                paste_sprite(img, SHADOW, cam((g.mid[0], 0.0, g.mid[2])), KNEE_SHADOW)
            pen = _Pen(img, cam)
        elif kind == "trunk":
            _draw_trunk(pen, body.trunk)
        elif kind == "head":
            _draw_head(pen, body.head)
        elif kind == "arm":
            _draw_arm(pen, body.arms[name])
        elif kind in ("leg", "thigh", "shin"):
            _draw_leg(pen, body.legs[name], kind)
        else:
            raise ValueError("unknown layer %r" % layer)
    if "glow" not in body.layers:
        glow()


def draw_guide(img: Image.Image, cam: Camera, points, alpha: float) -> None:
    """studio's green dashed guide through the projected 3D points."""
    if alpha <= 0:
        return
    ov = Image.new("RGBA", img.size, (0, 0, 0, 0))
    dashed_line(ImageDraw.Draw(ov), [cam(p) for p in points], alpha)
    img.alpha_composite(ov)


def _mat(d, cam, x0, x1, z0, z1, *, edge=8, shadow=True):
    """A mat on the floor, x0..x1 by z0..z1: its top, the thickness of the
    edges that face the camera, and a soft-edged shadow under the near edge."""
    top = [cam((x0, 0, z0)), cam((x1, 0, z0)), cam((x1, 0, z1)), cam((x0, 0, z1))]
    near = [top[3], top[2]]

    def down(pts, dy):
        return [(x, y + dy) for x, y in pts]

    if shadow:
        (ax, ay), (bx, by) = near
        d.polygon([((ax - 10) * S, (ay + edge - 2) * S), ((bx + 10) * S, (by + edge - 2) * S),
                   ((bx + 4) * S, (by + edge + 8) * S), ((ax - 4) * S, (ay + edge + 8) * S)],
                  fill=(40, 42, 48))
    d.polygon([(x * S, y * S) for x, y in _hull(top + down(top, edge))], fill=MAT_SIDE)
    d.polygon([(x * S, y * S) for x, y in top], fill=MAT)


# ---------- lying on the side, seen from the front ----------
# She lies on her right side along the mat, head to the left, facing the
# camera, which looks down at her from a little above.
SIDE_CAM = Camera(origin=(0, 598), elevation=30)
SIDE_SPINE_Y = 42            # spine height above the mat: the shoulders and hips lie stacked
SIDE_SHOULDER_X = 470
SIDE_PELVIS_X = SIDE_SHOULDER_X + TORSO
SIDE_HIPS = {"bottom": (SIDE_PELVIS_X, SIDE_SPINE_Y - HIP_HALF, 0.0),
             "top": (SIDE_PELVIS_X, SIDE_SPINE_Y + HIP_HALF, 0.0)}
SIDE_LAYERS = ("arm bottom", "leg bottom", "trunk", "head", "leg top", "arm top")
_SIDE_MAT = (180, 1090, -60, 200)     # x0, x1, z0, z1 of the mat she lies on


def side_lying(legs: dict) -> Body:
    """Lying on the right side, head to the left, the head resting on the
    lower arm stretched along the mat beyond it; the upper arm props her on
    the mat in front of her chest, elbow down, forearm and hand flat on the
    mat toward her head, clear of the hips. legs: "top" and "bottom" Limbs
    (see leg())."""
    up, front = (0.0, 1.0, 0.0), (0.0, 0.0, 1.0)
    sh = (SIDE_SHOULDER_X, SIDE_SPINE_Y, 0.0)
    trunk = Trunk(sh, (SIDE_PELVIS_X, SIDE_SPINE_Y, 0.0), across=up, front=front)
    centre = (SIDE_SHOULDER_X - NECK, SIDE_SPINE_Y + 4, 2.0)
    head = Head(centre, face=front, crown=(-1.0, 0.0, 0.0), neck=add(sh, (-10, 0, 0)))
    bottom_root = (SIDE_SHOULDER_X + 4, SIDE_SPINE_Y - ARM_ROOT + 2, -2.0)
    arms = {
        "bottom": straight_arm(bottom_root, (-1.0, -0.06, -0.02), shade=1.0),
        "top": _propping_arm((SIDE_SHOULDER_X + 4, SIDE_SPINE_Y + ARM_ROOT - 2, 0.0)),
    }
    return Body(trunk, head, arms, legs, SIDE_LAYERS)


PROP_ELBOW_X = 46            # the propping elbow, this far toward the feet from the shoulder
PROP_FOREARM = (-0.88, 0.0, 0.47)   # its forearm on the mat, toward the head and the camera


def _propping_arm(root) -> Limb:
    """The upper arm down to an elbow on the mat in front of the chest, the
    forearm and hand flat on the mat."""
    y = 8.0                                     # the forearm's radius: resting on the mat
    dx, dy = PROP_ELBOW_X, y - root[1]
    elbow = (root[0] + dx, y, root[2] + math.sqrt(UPPER_ARM ** 2 - dx * dx - dy * dy))
    wrist = add(elbow, mul(PROP_FOREARM, FOREARM))
    return Limb(root, elbow, (wrist[0], _HAND_R[1], wrist[2]), PROP_FOREARM)


def side_room(room: Image.Image) -> Image.Image:
    """The gym room with a mat deep enough to lie on sideways (cached per room)."""
    cached = _ROOMS.get("side")
    if cached is not None and cached[0] is room:
        return cached[1]
    img = room.copy()
    _mat(ImageDraw.Draw(img), SIDE_CAM, *_SIDE_MAT)
    _ROOMS["side"] = (room, img)
    return img


_ROOMS: dict = {}


# ---------- lying on the back, seen from the feet ----------
# The camera stands beyond her feet, low and square on, looking along her
# toward her head: the knees peak in front of her, and lower the same way to
# either side.
FEET_CAM = Camera(origin=(640, 470), elevation=28, distance=1400, scale=1.22)
SUPINE_SPINE_Y = 24          # spine height above the mat lying on the back (figure.py's)
SUPINE_HIPS = {"left": (-HIP_HALF, SUPINE_SPINE_Y, 0.0), "right": (HIP_HALF, SUPINE_SPINE_Y, 0.0)}
_FEET_MAT = (-290, 290, -385, 240)
ARM_SPREAD = 62.0            # degrees each arm lies out from the body


def supine(legs: dict, roll: float = 0.0, layers=None) -> Body:
    """Lying on the back seen from the feet, arms spread wide on the mat.
    legs: "left" and "right" (of the picture), e.g. from knees_bent(). roll:
    degrees the pelvis turns, + lifting the right hip as the knees go left."""
    up = (0.0, 1.0, 0.0)
    pelvis = (0.0, SUPINE_SPINE_Y, 0.0)
    sh = (0.0, SUPINE_SPINE_Y, -TORSO)
    # the trunk rolls about pelvis -> shoulder (-z); the hips turned about +z
    trunk = Trunk(sh, pelvis, across=(1.0, 0.0, 0.0), front=up, roll=-roll, seat_shade=0.6)
    head = Head((0.0, SUPINE_SPINE_Y + 3, -TORSO - NECK), face=up, crown=(0.0, 0.0, -1.0),
                neck=add(sh, (0, 0, -10)))
    arms = {}
    for name, side in (("left", -1), ("right", 1)):
        a = math.radians(ARM_SPREAD)
        root = (side * ARM_ROOT, SUPINE_SPINE_Y - 6, -TORSO + 6)
        arms[name] = straight_arm(root, (side * math.sin(a), -0.04, math.cos(a)))
    layers = layers or supine_layers(0.0)
    return Body(trunk, head, arms, legs, layers)


SUPINE_ANKLE_Z = 190.0       # feet flat, this far toward the camera from the hips
PELVIS_FOLLOW = 0.35         # how much of the knees' turn the pelvis follows
THIGH_SHADE = 0.25          # the thighs, a little in shade beside the shins
FEET_HALF = 55.0             # centre -> each ankle: knees together, feet apart, so the
                             # shins splay down from the knees in an upside-down V
TOE_OUT = 20.0               # degrees each foot turns out: the shoe shows its side, flat on the mat
KNEECAP = 15.5               # the knees, nearest the camera, catch the light
KNEE_LIGHT = 0.35            # how much lighter the kneecaps are (toward WAISTBAND)
KNEE_SHADOW = 0.55           # the knees' shadow on the mat between the feet


def knees_bent(drop: float = 0.0) -> tuple[dict, float]:
    """Both legs bent, knees together, feet flat and apart; the knees lowered
    `drop` degrees together to the picture's left (- to the right), the feet
    staying where they are. The knees turn as a pair about the line from the
    hips to the feet; the pelvis follows a little of the turn. Returns the
    legs and the pelvis roll for supine(). The thighs, seen past the shins,
    are in shade; the leg that goes underneath darkens as it lowers (its
    planted shoe does not)."""
    mid_hip, mid_ankle = (0.0, SUPINE_SPINE_Y, 0.0), (0.0, 21.0, SUPINE_ANKLE_Z)
    knee0 = two_bone(mid_hip, mid_ankle, THIGH, SHIN, (0.0, 1.0, 0.0))
    knee = add(mid_hip, rotate(sub(knee0, mid_hip), unit3(sub(mid_ankle, mid_hip)), drop))
    roll = drop * PELVIS_FOLLOW
    out = {}
    for name, side in (("left", -1), ("right", 1)):
        hip = add(mid_hip, rotate((side * HIP_HALF, 0.0, 0.0), (0.0, 0.0, 1.0), roll))
        target = add(knee, rotate((side * 15.0, 0.0, 0.0), (0.0, 0.0, 1.0), drop))
        under = min(1.0, abs(drop) / 35.0) if (side < 0) == (drop > 0) else 0.0
        toe = math.radians(side * TOE_OUT)
        out[name] = leg(hip, (side * FEET_HALF, 21.0, SUPINE_ANKLE_Z), sub(target, hip),
                        (math.sin(toe), 0.0, math.cos(toe)), shade=0.8 * under, kneecap=KNEECAP,
                        upper_shade=THIGH_SHADE + (1 - THIGH_SHADE) * under,
                        foot_up=(0.0, 1.0, 0.0), foot_shade=0.0)
    return out, roll


def supine_layers(drop: float) -> tuple:
    """Paint order for supine(): the leg the knees lower toward goes first.
    Both thighs go before both shins, so at rest, where the side changes, the
    two orders paint the same picture. The glow goes on the trunk, under the
    legs, so it never lights a knee."""
    first, second = ("left", "right") if drop >= 0 else ("right", "left")
    return ("head", "arm left", "arm right", "trunk", "glow", "shadow", "thigh " + first,
            "thigh " + second,
            "shin " + first, "shin " + second)


def feet_room() -> Image.Image:
    """The gym room seen from above a mat laid out toward the camera: the
    same wall, stripe, window and clock, more floor."""
    if "feet" in _ROOMS:
        return _ROOMS["feet"]
    bg = Image.new("RGBA", (W * S, H * S))
    d = ImageDraw.Draw(bg)
    wall = 196
    for y in range(wall):
        t = y / wall
        c = tuple(int(a + (b - a) * t) for a, b in zip((236, 239, 243), (212, 218, 227)))
        d.rectangle([0, y * S, W * S, (y + 1) * S], fill=c)
    for y in range(wall, H):
        t = (y - wall) / (H - wall)
        c = tuple(int(a + (b - a) * t) for a, b in zip((84, 88, 98), (52, 55, 63)))
        d.rectangle([0, y * S, W * S, (y + 1) * S], fill=c)
    for yy in (214, 246, 292, 356, 444, 560, 700):
        d.line([(0, yy * S), (W * S, yy * S)], fill=(96, 100, 110), width=S)
    d.rectangle([0, 128 * S, W * S, 138 * S], fill=(120, 190, 182))        # wall stripe
    d.rectangle([0, (wall - 8) * S, W * S, wall * S], fill=(186, 192, 200))  # baseboard
    # window, as make_room's but smaller
    x0, y0, x1, y1 = 120, 16, 300, 116
    d.rectangle([x0 * S, y0 * S, x1 * S, y1 * S], fill=(196, 202, 210))
    for y in range(y0 + 7, y1 - 7):
        t = (y - y0 - 7) / (y1 - y0 - 14)
        c = tuple(int(a + (b - a) * t) for a, b in zip((176, 214, 240), (222, 238, 248)))
        d.rectangle([(x0 + 7) * S, y * S, (x1 - 7) * S, (y + 1) * S], fill=c)
    d.rectangle([((x0 + x1) / 2 - 3) * S, y0 * S, ((x0 + x1) / 2 + 3) * S, y1 * S], fill=(196, 202, 210))
    d.rectangle([x0 * S, ((y0 + y1) / 2 - 3) * S, x1 * S, ((y0 + y1) / 2 + 3) * S], fill=(196, 202, 210))
    # wall clock
    cx, cy = 1080, 64
    circle(d, (cx, cy), 34, (70, 74, 84))
    circle(d, (cx, cy), 30, (250, 250, 252))
    d.line([cx * S, cy * S, cx * S, (cy - 20) * S], fill=(50, 50, 60), width=3 * S)
    d.line([cx * S, cy * S, (cx + 15) * S, (cy + 9) * S], fill=(50, 50, 60), width=3 * S)
    circle(d, (cx, cy), 3, TOP)
    # exercise ball and kettlebells against the wall
    circle(d, (150, 200), 44, (140, 110, 190))
    circle(d, (137, 185), 13, (166, 140, 212))
    for kx, kr in ((1110, 18), (1166, 22)):
        d.arc([(kx - 12) * S, (226 - kr - 16) * S, (kx + 12) * S, (226 - kr + 8) * S], 180, 360,
              fill=(40, 42, 48), width=6 * S)
        circle(d, (kx, 226), kr, (40, 42, 48))
    _mat(d, FEET_CAM, *_FEET_MAT, edge=10)
    _ROOMS["feet"] = bg
    return bg


# ---------- reference poses ----------
def render_poses(out: Path) -> None:
    """The exercises' own start and end poses in these views."""
    import studio
    from exercises import clamshells, side_leg_raise
    room = studio.make_room()
    panels = []
    for legs in (clamshells.legs(0.0), clamshells.legs(1.0),
                 {"bottom": side_leg_raise.BOTTOM, "top": side_leg_raise.top_leg(0.0)[0]}):
        img = side_room(room).copy()
        draw_front_figure(img, side_lying(legs), SIDE_CAM)
        panels.append(img)
    for drop in (0.0, 35.0):
        img = feet_room().copy()
        legs, roll = knees_bent(drop)
        draw_front_figure(img, supine(legs, roll, supine_layers(drop)), FEET_CAM)
        panels.append(img)
    tw, th, cols = W // 2, H // 2, 3
    rows = -(-len(panels) // cols)
    sheet = Image.new("RGB", (tw * cols, th * rows), (40, 42, 48))
    for i, img in enumerate(panels):
        sheet.paste(img.convert("RGB").resize((tw, th), Image.LANCZOS), ((i % cols) * tw, (i // cols) * th))
    out.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out)
    print("poses", out)


if __name__ == "__main__":
    if "--poses" not in sys.argv[1:]:
        print(__doc__.split("\n\n")[1])
        sys.exit(2)
    render_poses(HERE.parents[1] / "build" / "exercise_videos" / "poses_front.png")
