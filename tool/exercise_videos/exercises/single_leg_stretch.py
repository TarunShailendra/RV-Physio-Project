"""Single leg stretch, lying on the back, head down.

Both knees are drawn up toward the chest. The near leg straightens out low,
close to the mat, while the far knee is drawn a little closer in; hold; back
to both knees in. Then the far leg does the same. The trunk and head stay
flat on the mat, the belly glowing while a leg is out. Two held sides, each
rest 0.4 s, extend 1.3 s, plateau 0.8 s, return 1.3 s, rest 0.4 s.
"""
from dataclasses import replace

from PIL import Image

from figure import SIDE_SUPINE_KNEES_BENT, draw_side_figure, lerp_pose, plant_foot, pose_points
from spec import VideoSpec
from studio import H, W

from ._motion import REST, phase, side

ROOT = (600.0, 560.0)
TUCK = dict(hip=115.0, knee=115.0, ankle=20.0)     # knee toward the chest, shin level
PULL = dict(hip=123.0, knee=121.0, ankle=20.0)     # the staying knee drawn a little closer
LONG = dict(hip=18.0, knee=0.0, ankle=40.0)        # straight, low, toes pointed
GLOW_PEAK = 0.45


def _legs(near, far):
    kw = {f"near_{k}": v for k, v in near.items()} | {f"far_{k}": v for k, v in far.items()}
    return replace(SIDE_SUPINE_KNEES_BENT, root=ROOT, **kw)


TUCKED = _legs(TUCK, TUCK)
NEAR_OUT = _legs(LONG, PULL)
FAR_OUT = _legs(PULL, LONG)

S1 = side(0.0, 1.3, 0.8, 1.3)
S2 = side(S1.out_end + REST, 1.3, 0.8, 1.3)
DURATION = S2.out_end + REST


def _lerp(a, b, k):
    return (a[0] + (b[0] - a[0]) * k, a[1] + (b[1] - a[1]) * k)


def pose(leg, e):
    """The `leg` ("near" or "far") at e of the way out. Its ankle travels in a
    straight line from the tuck to the low, straight position, so the leg
    pushes out rather than kicking up; the other knee draws in by blending."""
    out = NEAR_OUT if leg == "near" else FAR_OUT
    p = lerp_pose(TUCKED, out, e)
    a0, a1 = (pose_points(q)[leg + "_ankle"] for q in (TUCKED, out))
    p = plant_foot(p, leg, _lerp(a0, a1, e))
    return replace(p, **{leg + "_ankle": TUCK["ankle"] + (LONG["ankle"] - TUCK["ankle"]) * e})


def frame(t, room):
    e1, e2 = phase(t, S1), phase(t, S2)
    p = pose("near", e1) if e1 > 0 else pose("far", e2)
    img = room.copy()
    draw_side_figure(img, p, glow_at="belly", glow_k=GLOW_PEAK * max(e1, e2))
    return img.convert("RGB").resize((W, H), Image.LANCZOS)


VIDEOS = [
    VideoSpec(id="single_leg_stretch", exercise_key="single_leg_stretch", position="supine",
              duration=DURATION, sides=(S1, S2), props=frozenset(), frame=frame),
]
