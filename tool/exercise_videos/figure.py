"""A posable side-view figure: the owner's bridge.py woman on a joint-angle rig.

    python tool/exercise_videos/figure.py --poses

writes build/exercise_videos/poses.png: the four reference poses, then standing
with a hand on the chair's backrest and lying with hands on chest and belly.

Every shape (head, hair, bun, ear, nose, torso profile, limb radii, shoes) is
the one bridge.py draws; this module only lets it bend. Each piece is stored
as bridge.py's own screen offsets in the frame of the bone it hangs from, as
that bone lies in the bridge's rest pose, and is rotated with the bone. In the
bridge's rest pose every rotation is zero, so the drawing is bridge.py's.

Angles (degrees). The figure is built facing right (SidePose.facing = 1) and
mirrored for facing = -1, so every angle is "as if facing right":

    trunk     direction pelvis -> shoulder: 0 upright, +90 lying face down /
              on hands and knees (head to the right), -90 lying on the back
              (head to the left, as in the bridge). + leans forward.
    neck      head relative to trunk; + tips the chin toward the chest.
    shoulder  arm relative to trunk; 0 hanging along the body, + raises it
              forward (90 straight ahead, 180 overhead).
    elbow     + bends the forearm forward (flexion); 0 straight.
    wrist     + tips the hand forward; 90 lays the hand flat on the floor
              under a vertical forearm.
    hip       thigh relative to trunk; 0 in line with the trunk, + flexes the
              thigh forward (90 seated).
    knee      + bends the shin back (flexion); 0 straight.
    ankle     0 foot at right angles to the shin, + points the toes.

Planted feet and hands are solved with bridge.py's two-bone IK (knee_ik,
plant_foot, place_hand, hand_on) and turned back into angles, so poses stay
plain data that lerp_pose can blend.
"""
import math
import sys
from dataclasses import dataclass, fields, replace
from pathlib import Path
from typing import Literal

from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

from studio import (GLOW, HAIR, LEG, LEG_D, S, SHOE, SHOE_D, SKIN, SKIN_D, TOP, H,  # noqa: E402
                    W, capsule, circle, paste_sprite, unit)

# ---------- bridge.py's measurements ----------
TORSO, THIGH, SHIN = 190, 170, 165
UPW = [(0, 25), (0.25, 30), (0.5, 22), (0.8, 24), (1, 27)]   # front (belly side) half-width
DNW = [(0, 25), (0.3, 25), (0.6, 22), (1, 27)]                # back half-width
WAISTBAND = (90, 86, 150)
FAR_SOLE = (190, 80, 95)

# Rest pose = bridge.py at elevation 0, pelvis at (620, 560). Offsets below are
# bridge.py's screen offsets in that pose (x right, y down).
_REST_TRUNK = -90.0
_REST_HEAD = -90.0
_SHOULDER = (-TORSO, 0)            # pelvis -> shoulder
_FAR_HIP = (3, -3)                 # pelvis -> far hip, fixed on screen: the far side sits a
                                   # little higher, further from the camera, in every pose
_HEAD = (-60, -1)                  # shoulder -> head centre
_NECK_A, _NECK_B = (-12, 0), (16, 2)   # shoulder -> neck start; head centre -> neck end
_NOSE = (8, -27)
_EAR, _EAR_R = (3.5, 1), (5.5, 7)
_HAIR_ARC = (70, 255)
_TIE = (-24, 15)
_TAIL, _TAIL_R = (-31, 2), (35, 10)    # tie -> ponytail centre, lying on the floor
# bridge.py's arms reach only to the hip (shoulder -> hand 0.9x the torso),
# too short to stand holding a chair or rest a hand on a thigh. They are
# lengthened to about human reach (1.3x the torso); a flat arm keeps
# bridge.py's height on the mat and just reaches further along it.
ARM_REACH = 1.5
_ARM_ROOT = (4, 6)                 # shoulder -> top of upper arm
_UPPER = (84 * ARM_REACH, 10)      # -> elbow
_FORE = (74 * ARM_REACH, 2)        # elbow -> wrist
_HAND, _HAND_R = (8, 0), (12, 6)   # wrist -> hand centre; hand ellipse radii
_SHIN_END = (-2, -4)               # ankle -> end of shin capsule (foot flat)
_SHOE = [(-12, -8), (10, -11), (26, 0), (50, 8), (55, 18), (-16, 18)]
_SOLE = [(-17, 15), (56, 15), (56, 21), (-17, 21)]
_HEEL, _TOE = (-16, 18), (55, 18)


def _lean(a):
    """Unit vector for a direction a degrees clockwise from straight up."""
    r = math.radians(a)
    return (math.sin(r), -math.cos(r))


def _lean_of(v):
    return math.degrees(math.atan2(v[0], -v[1]))


def _rot(v, phi):
    """v rotated phi degrees clockwise on screen."""
    if phi == 0:
        return v
    c, s = math.cos(math.radians(phi)), math.sin(math.radians(phi))
    return (v[0] * c - v[1] * s, v[0] * s + v[1] * c)


def _add(a, b):
    return (a[0] + b[0], a[1] + b[1])


def _sub(a, b):
    return (a[0] - b[0], a[1] - b[1])


def _mul(a, k):
    return (a[0] * k, a[1] * k)


def _lerp(a, b, k):
    return (a[0] + (b[0] - a[0]) * k, a[1] + (b[1] - a[1]) * k)


def _wrap(a):
    """a in [-180, 180)."""
    return (a + 180.0) % 360.0 - 180.0


_B0 = _lean_of(_UPPER)             # upper-arm direction at rest
_F0 = _lean_of(_FORE)              # forearm (and hand) direction at rest
_U0 = _add(_ARM_ROOT, _UPPER)      # shoulder -> elbow at rest


def _lerpw(table, f):
    for (f0, w0), (f1, w1) in zip(table, table[1:]):
        if f0 <= f <= f1:
            return w0 + (w1 - w0) * (f - f0) / (f1 - f0)
    return table[-1][1]


def _bump(f, centre, half):
    x = (f - centre) / half
    return 0.5 + 0.5 * math.cos(math.pi * x) if -1 < x < 1 else 0.0


_BELLY = (0.7, 0.24)     # where `belly` pushes the front out (fraction shoulder -> hip)
_LUMBAR = (0.64, 0.24)   # where `lumbar` fills the hollow of the lower back


def _front_w(f, belly):
    return _lerpw(UPW, f) + (belly * _bump(f, *_BELLY) if belly else 0)


def _back_w(f, lumbar):
    return _lerpw(DNW, f) + (lumbar * _bump(f, *_LUMBAR) if lumbar else 0)


# ---------- the pose ----------
@dataclass(frozen=True)
class SidePose:
    """A side-view pose. root is the pelvis (hip joint) in 1280x720 pixels;
    angles in degrees as described in the module docstring."""
    root: tuple[float, float]
    trunk: float = 0.0
    neck: float = 0.0
    near_shoulder: float = 0.0
    near_elbow: float = 0.0
    near_wrist: float = 0.0
    far_shoulder: float = 0.0
    far_elbow: float = 0.0
    far_wrist: float = 0.0
    # Seen length of each arm bone, 1 = full. Less draws it foreshortened, as
    # when an elbow rests out to the side (place_hand with a pinned elbow).
    near_upper_arm: float = 1.0
    near_forearm: float = 1.0
    far_upper_arm: float = 1.0
    far_forearm: float = 1.0
    near_hip: float = 0.0
    near_knee: float = 0.0
    near_ankle: float = 0.0
    far_hip: float = 0.0
    far_knee: float = 0.0
    far_ankle: float = 0.0
    belly: float = 0.0     # px the belly pushes out (breathing in)
    lumbar: float = 0.0    # px added to the lower back: + flattens it (posterior tilt), - arches it
    scale: float = 1.0     # 1 = bridge.py's size
    facing: int = 1        # 1 faces right (head left when supine), -1 mirrored


_NUMERIC = [f.name for f in fields(SidePose) if f.name not in ("root", "facing")]


def lerp_pose(a: SidePose, b: SidePose, k: float) -> SidePose:
    """Straight-line blend of every field; k = 0 gives a, 1 gives b."""
    if a.facing != b.facing:
        raise ValueError("cannot blend poses facing opposite ways")
    vals = {n: getattr(a, n) + (getattr(b, n) - getattr(a, n)) * k for n in _NUMERIC}
    return SidePose(root=_lerp(a.root, b.root, k), facing=a.facing, **vals)


# ---------- inverse kinematics ----------
def _two_bone(a, c, l1, l2, side):
    """Middle joint of a chain a-(l1)-?-(l2)-c. side -1 bends it to the left of
    a->c (up, for a chain running right), +1 to the right. bridge.py's knee_ik."""
    dx, dy = c[0] - a[0], c[1] - a[1]
    dist = max(1e-6, min(math.hypot(dx, dy), l1 + l2 - 0.01))
    base = math.atan2(dy, dx)
    al = math.acos(max(-1.0, min(1.0, (l1 ** 2 + dist ** 2 - l2 ** 2) / (2 * l1 * dist))))
    return (a[0] + l1 * math.cos(base + side * al), a[1] + l1 * math.sin(base + side * al))


def knee_ik(hip, ankle, *, bend: Literal["up", "down"]):
    """bridge.py's two-bone IK for a full-size leg (thigh 170, shin 165), in
    screen pixels. "up" puts the knee on the left of the hip->ankle line as
    you look along it: up for a leg lying with the foot to the right (as
    bridge.py), forward for a standing leg facing right. "down" mirrors it."""
    return _two_bone(hip, ankle, THIGH, SHIN, -1 if bend == "up" else 1)


def _to_local(pose, p):
    x, y = (p[0] - pose.root[0]) / pose.scale, (p[1] - pose.root[1]) / pose.scale
    return (x * pose.facing, y)


def _to_screen(pose, p):
    x = pose.root[0] + p[0] * pose.facing * pose.scale
    y = pose.root[1] + p[1] * pose.scale
    return (round(x, 9), round(y, 9))


def _phi_t(pose):
    return pose.trunk - _REST_TRUNK


def _hip_local(side):
    return (0.0, 0.0) if side == "near" else _FAR_HIP


def _shoulder_local(pose):
    return _rot(_SHOULDER, _phi_t(pose))


def plant_foot(pose: SidePose, side: Literal["near", "far"], ankle, *, foot: float = 90.0) -> SidePose:
    """pose with this side's hip, knee and ankle angles set so the ankle sits at
    `ankle` (screen pixels) with the knee bent the natural way, and the foot
    pointing `foot` degrees clockwise from straight up in the figure's own
    frame (90 = flat on the floor, toes forward; 270 = lying along the floor
    pointing back with the sole up, as on hands and knees). bridge.py's feet
    are ankle (800, 566) near and (786, 564) far, foot 90."""
    hip = _hip_local(side)
    target = _to_local(pose, ankle)
    knee = _two_bone(hip, target, THIGH, SHIN, -1)
    thigh = _lean_of(_sub(knee, hip))
    shin = _lean_of(_sub(target, knee))
    return replace(pose, **{
        side + "_hip": _wrap(pose.trunk + 180 - thigh),
        side + "_knee": _wrap(shin - thigh),
        side + "_ankle": _wrap(foot - shin + 90),
    })


def place_hand(pose: SidePose, side: Literal["near", "far"], hand, *,
               hand_angle: float | None = None,
               elbow: Literal["down", "up"] | tuple[float, float] = "down") -> SidePose:
    """pose with this side's shoulder and elbow (and wrist, if hand_angle is
    given) set so the centre of the hand lands on `hand` (screen pixels).
    hand_angle is the direction the fingers point, degrees clockwise from up
    in the figure's own frame (90 = forward).

    elbow "down" bends the arm the natural way (the elbow behind the line from
    shoulder to hand, as the figure faces), "up" the other way. A screen point
    pins the elbow there instead (e.g. resting on the mat while the hand is on
    the chest): the bones are then drawn foreshortened, as an arm whose elbow
    sits out to the side; a bone never gets longer than full length."""
    s = _shoulder_local(pose)
    target = _to_local(pose, hand)
    wrist = getattr(pose, side + "_wrist")
    lu, lf = 1.0, 1.0
    if isinstance(elbow, str):
        bend = 1 if elbow == "down" else -1
        for _ in range(6 if hand_angle is not None else 1):
            v0 = _add(_FORE, _rot(_HAND, -wrist))          # elbow -> hand centre at rest
            e = _two_bone(s, target, math.hypot(*_U0), math.hypot(*v0), bend)
            upper = _B0 + _lean_of(_sub(e, s)) - _lean_of(_U0)
            fore = _F0 + _lean_of(_sub(target, e)) - _lean_of(v0)
            if hand_angle is not None:
                wrist = _wrap(fore - hand_angle)
    else:
        pin = _to_local(pose, elbow)
        upper = _B0 + _lean_of(_sub(pin, s)) - _lean_of(_U0)
        for _ in range(4):                                  # the arm's root moves with it
            root = _add(s, _rot(_ARM_ROOT, upper - _B0))
            lu = min(1.0, math.dist(root, pin) / math.hypot(*_UPPER))
            upper = _B0 + _lean_of(_sub(pin, root)) - _lean_of(_UPPER)
        e = _add(root, _mul(_rot(_UPPER, upper - _B0), lu))
        fore = _F0 + _lean_of(_sub(target, e)) - _lean_of(_FORE)
        for _ in range(6):                                  # the hand hangs off the wrist
            hand_abs = hand_angle if hand_angle is not None else fore - wrist
            v = _sub(_sub(target, e), _rot(_HAND, hand_abs - _F0))
            lf = max(0.15, min(1.0, math.hypot(*v) / math.hypot(*_FORE)))
            fore = _F0 + _lean_of(v) - _lean_of(_FORE)
        if hand_angle is not None:
            wrist = _wrap(fore - hand_angle)
    return replace(pose, **{
        side + "_shoulder": _wrap(pose.trunk + 180 - upper),
        side + "_elbow": _wrap(upper - fore),
        side + "_wrist": wrist,
        side + "_upper_arm": lu,
        side + "_forearm": lf,
    })


def hand_on(pose: SidePose, side: Literal["near", "far"],
            part: Literal["chest", "belly", "thigh"]) -> SidePose:
    """pose with this side's hand resting flat on the chest, the belly (both
    follow `belly`) or its own thigh, fingers toward the head (chest, belly)
    or the knee (thigh). Call after the rest of the pose is set.

    On the chest or belly the elbow rests out to the side: on the floor beside
    the trunk when lying on the back, by the waist otherwise."""
    sh = _shoulder_local(pose)
    if part == "thigh":
        j, _ = _local_joints(pose)
        hip, knee = j[side + "_hip"], j[side + "_knee"]
        d = unit(hip, knee)
        out = (d[1], -d[0])             # thigh's front: up for a seated thigh
        reach = math.hypot(*_U0) + math.hypot(*_add(_FORE, _HAND))
        # the point along the thigh that leaves the elbow softly bent
        p = min((_add(_lerp(hip, knee, t), _mul(out, 23 - 8 * t - 3)) for t in
                 (i / 20 for i in range(2, 16))),
                key=lambda q: abs(math.dist(sh, q) - 0.9 * reach))
        return place_hand(pose, side, _to_screen(pose, p), hand_angle=_lean_of(d))
    f = 0.25 if part == "chest" else _BELLY[0]
    u = unit((0, 0), sh)
    front = (-u[1], u[0])
    p = _add(_lerp(sh, (0, 0), f), _mul(front, _front_w(f, pose.belly) + 5))
    supine = front[1] < -0.7            # front faces up: the back is on the floor
    # elbow: along the trunk from the shoulder, and toward the back (on the
    # floor when supine, as bridge.py's flat arm lies)
    elbow = _add(_lerp(sh, (0, 0), 0.42), _mul(front, -17 if supine else -6))
    return place_hand(pose, side, _to_screen(pose, p), hand_angle=pose.trunk,
                      elbow=_to_screen(pose, elbow))


# ---------- forward kinematics ----------
def _local_joints(pose):
    """Joint positions and bone rotations in the figure's own frame (pelvis at
    the origin, facing right, scale 1)."""
    j, rot = {}, {}
    pt = _phi_t(pose)
    sh = _rot(_SHOULDER, pt)
    j["pelvis"], j["shoulder"] = (0.0, 0.0), sh
    rot["trunk"] = pt
    head_abs = pose.trunk + pose.neck
    ph = head_abs - _REST_HEAD
    rot["head"] = ph
    j["head"] = _add(sh, _rot(_HEAD, ph))
    for side in ("near", "far"):
        upper = pose.trunk + 180 - getattr(pose, side + "_shoulder")
        fore = upper - getattr(pose, side + "_elbow")
        hand = fore - getattr(pose, side + "_wrist")
        pu, pf, pd = upper - _B0, fore - _F0, hand - _F0
        root = _add(sh, _rot(_ARM_ROOT, pu))
        j[side + "_arm"] = root
        j[side + "_elbow"] = _add(root, _mul(_rot(_UPPER, pu), getattr(pose, side + "_upper_arm")))
        j[side + "_wrist"] = _add(j[side + "_elbow"],
                                  _mul(_rot(_FORE, pf), getattr(pose, side + "_forearm")))
        j[side + "_hand"] = _add(j[side + "_wrist"], _rot(_HAND, pd))
        rot[side + "_hand"] = pd

        hip = _hip_local(side)
        thigh = pose.trunk + 180 - getattr(pose, side + "_hip")
        shin = thigh + getattr(pose, side + "_knee")
        foot = shin - 90 + getattr(pose, side + "_ankle")
        j[side + "_hip"] = hip
        j[side + "_knee"] = _add(hip, _mul(_lean(thigh), THIGH))
        j[side + "_ankle"] = _add(j[side + "_knee"], _mul(_lean(shin), SHIN))
        pft = foot - 90
        rot[side + "_foot"] = pft
        j[side + "_heel"] = _add(j[side + "_ankle"], _rot(_HEEL, pft))
        j[side + "_toe"] = _add(j[side + "_ankle"], _rot(_TOE, pft))
    # named body parts (glow spots)
    u = unit((0, 0), sh)
    front = (-u[1], u[0])
    on = lambda f: _lerp(sh, (0, 0), f)                                   # noqa: E731
    j["pelvic_floor"] = _rot((8, 0), pt)
    j["glutes"] = _rot((-6, 6), pt)
    j["belly"] = _add(on(_BELLY[0]), _mul(front, _front_w(_BELLY[0], pose.belly) - 12))
    j["chest"] = _add(on(0.25), _mul(front, 12))
    j["lower_back"] = _add(on(0.68), _mul(front, -12))
    for side in ("near", "far"):
        j[side + "_thigh"] = _lerp(j[side + "_hip"], j[side + "_knee"], 0.5)
        j[side + "_shin"] = _lerp(j[side + "_knee"], j[side + "_ankle"], 0.45)
    return j, rot


GLOW_PARTS = ("pelvic_floor", "glutes", "belly", "chest", "lower_back",
              "near_thigh", "far_thigh", "near_shin", "far_shin")


def pose_points(pose: SidePose) -> dict[str, tuple[float, float]]:
    """Screen positions of the joints and named parts (see draw_side_figure)."""
    j, _ = _local_joints(pose)
    return {k: _to_screen(pose, v) for k, v in j.items()}


# ---------- drawing ----------
class _Pen:
    """Draws figure-frame shapes onto the supersampled image."""

    def __init__(self, d, pose):
        self.d, self.p, self.k = d, pose, pose.scale

    def pt(self, p):
        return _to_screen(self.p, p)

    def circle(self, c, r, fill):
        circle(self.d, self.pt(c), r * self.k, fill)

    def capsule(self, a, b, ra, rb, fill):
        capsule(self.d, self.pt(a), self.pt(b), ra * self.k, rb * self.k, fill)

    def poly(self, pts, fill):
        self.d.polygon([(x * S, y * S) for x, y in (self.pt(p) for p in pts)], fill=fill)

    def ellipse(self, c, radii, phi, fill):
        """Ellipse with radii along the rest frame's x and y, turned phi degrees."""
        q = phi % 90
        if min(q, 90 - q) < 1e-7:
            rx, ry = radii if round(phi / 90) % 2 == 0 else radii[::-1]
            x, y = self.pt(c)
            rx, ry = rx * self.k, ry * self.k
            self.d.ellipse([(x - rx) * S, (y - ry) * S, (x + rx) * S, (y + ry) * S], fill=fill)
            return
        n = 48
        self.poly([_add(c, _rot((radii[0] * math.cos(2 * math.pi * i / n),
                                 radii[1] * math.sin(2 * math.pi * i / n)), phi))
                   for i in range(n)], fill)

    def pieslice(self, c, r, a0, a1, fill):
        if self.p.facing < 0:
            a0, a1 = 180 - a1, 180 - a0
        start = a0 % 360
        x, y = self.pt(c)
        r = r * self.k
        self.d.pieslice([(x - r) * S, (y - r) * S, (x + r) * S, (y + r) * S],
                        start, start + (a1 - a0), fill=fill)

    def torso(self, sh, hp, f0, f1, n, fill):
        """bridge.py's torso_poly, in screen space."""
        p = self.p
        SH, HP = self.pt(sh), self.pt(hp)
        ux, uy = unit(SH, HP)
        nx, ny = uy * p.facing, -ux * p.facing  # n points to the belly side
        if p.belly or p.lumbar:
            n *= 3                    # finer steps to carry the bumps
        top, bot = [], []
        for i in range(n + 1):
            f = f0 + (f1 - f0) * i / n
            px, py = SH[0] + (HP[0] - SH[0]) * f, SH[1] + (HP[1] - SH[1]) * f
            wu, wd = _front_w(f, p.belly) * self.k, _back_w(f, p.lumbar) * self.k
            top.append((px + nx * wu, py + ny * wu))
            bot.append((px - nx * wd, py - ny * wd))
        self.d.polygon([(x * S, y * S) for x, y in top + bot[::-1]], fill=fill)


def _shoe(pen, ankle, phi, fill, sole):
    pen.poly([_add(ankle, _rot(o, phi)) for o in _SHOE], fill)
    pen.poly([_add(ankle, _rot(o, phi)) for o in _SOLE], sole)


def _leg(pen, j, rot, side, col, shoe_fill, sole):
    hip, knee, ankle = j[side + "_hip"], j[side + "_knee"], j[side + "_ankle"]
    phi = rot[side + "_foot"]
    pen.capsule(hip, knee, 23, 15, col)
    pen.capsule(knee, _add(ankle, _rot(_SHIN_END, phi)), 15, 9, col)
    _shoe(pen, ankle, phi, shoe_fill, sole)


def _arm(pen, j, rot, side, col):
    pen.capsule(j[side + "_arm"], j[side + "_elbow"], 11, 8, col)
    pen.capsule(j[side + "_elbow"], j[side + "_wrist"], 8, 7, col)
    pen.ellipse(j[side + "_hand"], _HAND_R, rot[side + "_hand"], col)


def _smooth(x):
    x = max(0.0, min(1.0, x))
    return x * x * (3 - 2 * x)


def _head(pen, pose, j, rot):
    sh, hc, ph = j["shoulder"], j["head"], rot["head"]
    hf = _lean(pose.trunk + pose.neck + 90)            # face direction
    # The ponytail lies along the floor when the back of the head rests on it
    # (bridge.py) and otherwise hangs, down and a little behind the head.
    lying = _smooth((-hf[1] - 0.6) / 0.3)
    tie = _add(hc, _rot(_TIE, ph))
    if lying >= 1:
        psi = ph
    else:
        hang = _add((0, 1), _mul(hf, -0.35))
        # rotation taking the rest tail direction (-1, 0) onto `hang`
        psi_h = _lean_of(hang) - _lean_of((-1, 0))
        psi = ph + _wrap(psi_h - ph) * (1 - lying)
    tail_r = (_TAIL_R[0] - 9 * (1 - lying), _TAIL_R[1])
    tail = _add(tie, _rot(_add(_TAIL, (9 * (1 - lying), 0)), psi))
    pen.capsule(_add(sh, _rot(_NECK_A, ph)), _add(hc, _rot(_NECK_B, ph)), 11, 11, SKIN)
    if lying < 0.5:
        pen.ellipse(tail, tail_r, psi, HAIR)
    pen.circle(_add(hc, _rot(_NOSE, ph)), 6, SKIN)
    pen.circle(hc, 29, SKIN)
    pen.pieslice(hc, 31, _HAIR_ARC[0] + ph, _HAIR_ARC[1] + ph, HAIR)
    if lying >= 0.5:
        pen.ellipse(tail, tail_r, psi, HAIR)
    pen.circle(tie, 5, TOP)
    pen.ellipse(_add(hc, _rot(_EAR, ph)), _EAR_R, ph, SKIN_D)


def _pelvic_floor(img, pose, rot, k):
    """A warm sling across the base of the pelvis that lifts as k rises."""
    pt = rot["trunk"]
    a, b = _rot((-3, -17), pt), _rot((-3, 17), pt)
    c = _rot((15 - 7 * k, 0), pt)      # control point: the sling's low point rises
    pts = []
    for i in range(13):
        t = i / 12
        pts.append(_add(_add(_mul(a, (1 - t) ** 2), _mul(c, 2 * t * (1 - t))), _mul(b, t * t)))
    ov = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(ov)
    sp = [_to_screen(pose, p) for p in pts]
    w = 6 * pose.scale
    col = (255, 112, 64, int(240 * k))
    d.line([(x * S, y * S) for x, y in sp], fill=col, width=max(1, round(w * S)), joint="curve")
    for p in (sp[0], sp[-1]):
        circle(d, p, w / 2, col)
    img.alpha_composite(ov)


def draw_side_figure(img: Image.Image, pose: SidePose, *, glow_at: str | None = None,
                     glow_k: float = 0, highlight_pelvic_floor: float = 0
                     ) -> dict[str, tuple[float, float]]:
    """Draw the figure on the supersampled RGBA image img and return the screen
    positions of its joints and parts: pelvis, shoulder, head; near_/far_ +
    arm (top of the upper arm), elbow, wrist, hand, hip, knee, ankle, heel,
    toe, thigh, shin; pelvic_floor, glutes, belly, chest, lower_back.

    glow_at names one of GLOW_PARTS; the orange glow sits there at strength
    glow_k (bridge.py uses 0.45 at full effort). highlight_pelvic_floor (0..1)
    draws a sling across the base of the pelvis that lifts as it rises."""
    d = ImageDraw.Draw(img)
    pen = _Pen(d, pose)
    j, rot = _local_joints(pose)
    _leg(pen, j, rot, "far", LEG_D, SHOE_D, FAR_SOLE)
    _arm(pen, j, rot, "far", SKIN_D)
    _head(pen, pose, j, rot)
    sh, hp = j["shoulder"], j["pelvis"]
    pen.torso(sh, hp, 0, 1, 10, SKIN)
    pen.circle(sh, 24, SKIN)
    pen.torso(sh, hp, 0.1, 0.6, 10, TOP)
    pen.torso(sh, hp, 0.62, 1, 10, LEG)
    pen.torso(sh, hp, 0.62, 0.67, 2, WAISTBAND)
    pen.circle(hp, 27, LEG)  # glutes
    _leg(pen, j, rot, "near", LEG, SHOE, TOP)
    if highlight_pelvic_floor > 0.01:
        _pelvic_floor(img, pose, rot, highlight_pelvic_floor)
        d = ImageDraw.Draw(img)
        pen = _Pen(d, pose)
    _arm(pen, j, rot, "near", SKIN)
    pts = {k: _to_screen(pose, v) for k, v in j.items()}
    if glow_at is not None:
        if glow_at not in GLOW_PARTS:
            raise ValueError("unknown glow part %r" % glow_at)
        paste_sprite(img, GLOW, pts[glow_at], glow_k)
    return pts


# ---------- reference poses ----------
FLOOR = 596             # where the chair's legs (and a standing figure's soles) meet the floor
CHAIR_TOP = (591, 326)  # top of the chair prop's backrest, middle
_SOLE_DROP = 21         # ankle -> bottom of the sole, foot flat, full size
STANDING_SCALE = 0.86   # largest size whose head (top y ~48) clears the frame comfortably
                        # with the soles on FLOOR; a full-size standing figure is ~637 px


def _supine():
    p = SidePose(root=(620, 560), trunk=-90.0,
                 near_shoulder=_wrap(-90 + 180 - _B0), near_elbow=_B0 - _F0,
                 far_shoulder=_wrap(-90 + 180 - _B0), far_elbow=_B0 - _F0)
    p = plant_foot(p, "near", (800, 566))
    return plant_foot(p, "far", (786, 564))


def _sitting():
    # On the chair prop: seat top y 440 (x 576-722), backrest face x 606.
    p = SidePose(root=(633, 414), trunk=0.0)
    p = plant_foot(p, "near", (800, FLOOR - _SOLE_DROP))
    p = plant_foot(p, "far", (788, FLOOR - _SOLE_DROP - 2))
    p = hand_on(p, "near", "thigh")
    return hand_on(p, "far", "thigh")


def _standing(scale=STANDING_SCALE, x=524):
    # Soles on the floor line the chair stands on, just behind its backrest.
    ankle_y = FLOOR - _SOLE_DROP * scale
    p = SidePose(root=(x, ankle_y - (THIGH + SHIN) * scale), trunk=0.0, scale=scale,
                 near_elbow=8.0, far_elbow=8.0, far_shoulder=-4.0)
    p = plant_foot(p, "near", (x + 2 * scale, ankle_y))
    return plant_foot(p, "far", (x - 8 * scale, ankle_y - 2 * scale))


def _quadruped(x=480, trunk=73.0):
    # Knees on the mat (top y 584) under the hips; hands flat on the mat a
    # little ahead of the shoulders, elbows soft. With human-length arms the
    # shoulders ride higher than the hips, so the trunk slopes up a little.
    knee_y = 584 - 15 + 1
    p = SidePose(root=(x, knee_y - THIGH), trunk=trunk)
    for side, dx, dy in (("near", 0, 0), ("far", -10, -2)):
        # shin back along the mat from a knee under the hip, foot pointed
        ankle = _add((x + dx, knee_y + dy), _mul(_lean(268), SHIN))
        p = plant_foot(p, side, ankle, foot=270.0)
        sh = pose_points(p)["shoulder"]
        p = replace(p, **{side + "_wrist": 90.0})
        p = place_hand(p, side, (sh[0] + 35 + dx, 584 - 6 + 1 + dy), hand_angle=90.0)
    return p


SIDE_SUPINE_KNEES_BENT = _supine()   # bridge.py at rest, on the mat
SIDE_SITTING = _sitting()            # on the "chair" prop, hands on thighs
SIDE_STANDING = _standing()          # on the floor just behind the "chair" prop's backrest
SIDE_QUADRUPED = _quadruped()        # hands and knees on the mat

REFERENCE_POSES = {
    "supine_knees_bent": (SIDE_SUPINE_KNEES_BENT, frozenset()),
    "sitting": (SIDE_SITTING, frozenset({"chair"})),
    "standing": (SIDE_STANDING, frozenset({"chair"})),
    "quadruped": (SIDE_QUADRUPED, frozenset()),
}


def _sheet_panels():
    """The reference poses plus two built from them with the IK helpers."""
    hold = place_hand(SIDE_STANDING, "near", (CHAIR_TOP[0], CHAIR_TOP[1] - 4), hand_angle=100.0)
    breathe = hand_on(hand_on(SIDE_SUPINE_KNEES_BENT, "near", "chest"), "far", "belly")
    return [*REFERENCE_POSES.values(),
            (hold, frozenset({"chair"})),
            (breathe, frozenset())]


def render_pose(pose: SidePose, props=frozenset(), **kw) -> Image.Image:
    import studio
    img = studio.make_room(props)
    draw_side_figure(img, pose, **kw)
    return img.convert("RGB").resize((W, H), Image.LANCZOS)


def render_poses(out: Path) -> None:
    panels = _sheet_panels()
    tw, th, cols = W // 2, H // 2, 3
    rows = -(-len(panels) // cols)
    sheet = Image.new("RGB", (tw * cols, th * rows))
    for i, (pose, props) in enumerate(panels):
        sheet.paste(render_pose(pose, props).resize((tw, th), Image.LANCZOS),
                    ((i % cols) * tw, (i // cols) * th))
    out.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out)
    print("poses", out)


if __name__ == "__main__":
    if "--poses" not in sys.argv[1:]:
        print(__doc__.split("\n\n")[1])
        sys.exit(2)
    render_poses(HERE.parents[1] / "build" / "exercise_videos" / "poses.png")
