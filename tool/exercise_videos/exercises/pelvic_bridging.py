"""Pelvic bridging: one text-free rep of the owner's bridge.py, drawn through the rig.

Rest 0.4 s, lift 1.3 s, hold plateau 0.8 s, lower 1.5 s, rest 0.4 s.
"""
import math
from dataclasses import replace

from PIL import Image, ImageDraw

from figure import SIDE_SUPINE_KNEES_BENT, TORSO, draw_side_figure, knee_ik, plant_foot
from spec import SideTiming, VideoSpec
from studio import H, SHADOW, W, dashed_line, ease, paste_sprite, unit

# ---------- kinematics (from bridge.py) ----------
# The shoulders stay on the mat and the trunk pivots about them; the feet stay
# planted. Head and arms keep their place on the mat while the hips rise.
SH = (430, 560)
ANKLE, FAR_ANKLE = (800, 566), (786, 564)
THETA_MAX = math.radians(24)


def hip_point(e):
    th = THETA_MAX * e
    return (SH[0] + TORSO * math.cos(th), SH[1] - TORSO * math.sin(th))


def bridge_pose(e):
    """The rig's pose with the hips at elevation e (0..1)."""
    th = math.degrees(THETA_MAX * e)
    rest = SIDE_SUPINE_KNEES_BENT
    p = replace(rest, root=hip_point(e), trunk=rest.trunk - th, neck=rest.neck + th,
                near_shoulder=rest.near_shoulder - th, far_shoulder=rest.far_shoulder - th)
    p = plant_foot(p, "near", ANKLE)
    return plant_foot(p, "far", FAR_ANKLE)


def draw_figure(img, e):
    """Draw the figure (and its glute glow); return hip and near knee."""
    pts = draw_side_figure(img, bridge_pose(e), glow_at="glutes", glow_k=e * 0.45)
    return pts["pelvis"], pts["near_knee"]


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
    hp = hip_point(1)
    k = knee_ik(hp, ANKLE, bend="up")
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
    paste_sprite(img, SHADOW, (hip_point(e)[0] - 20, 588), e * 0.55)
    hp, k = draw_figure(img, e)
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
