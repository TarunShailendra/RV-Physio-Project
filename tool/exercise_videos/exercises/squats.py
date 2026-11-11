"""Squats, standing side-on behind the chair prop, hands on its backrest.

The figure faces right, standing just behind the chair with both hands on the
top of its backrest. She bends her knees and pushes her hips back and down,
as if sitting into a chair, the chest staying lifted (the trunk leans only as
far as balance over the feet needs) and the heels flat; then she pushes back
up to standing. The feet stay planted, the hands stay on the backrest, and
the knees stay clear of the chair. The thighs glow while she is down.
Unheld loop: rest 0.4 s, down 1.4 s, a 0.2 s pause, up 1.4 s, rest 0.4 s.
"""
import math

from PIL import Image

from figure import (FLOOR, SHIN, STANDING_SCALE, THIGH, SidePose, draw_side_figure, place_hand,
                    plant_foot)
from spec import VideoSpec
from studio import H, W

from ._motion import REST, phase, side

K = STANDING_SCALE
X0 = 504.0                         # standing hip: as far back as the hands still reach the backrest
ANKLE = (X0 + 2 * K, FLOOR - 21 * K)
FAR_ANKLE = (X0 - 8 * K, ANKLE[1] - 2 * K)
NEAR_HAND, FAR_HAND = (583.0, 321.0), (578.0, 322.0)   # on top of the backrest
SHIN_LEAN = 20.0                   # degrees: knees a little forward, clear of the chair, heels down
THIGH_DROP = 62.0                  # thigh from vertical at the bottom: a comfortable depth
TRUNK_LEAN = 35.0                  # hips back, chest lifted
GLOW_PEAK = 0.45


def _bottom_hip():
    s, t = math.radians(SHIN_LEAN), math.radians(THIGH_DROP)
    knee = (ANKLE[0] + SHIN * K * math.sin(s), ANKLE[1] - SHIN * K * math.cos(s))
    return (knee[0] - THIGH * K * math.sin(t), knee[1] - THIGH * K * math.cos(t))


TOP_HIP = (X0, ANKLE[1] - (THIGH + SHIN) * K)       # standing tall, as SIDE_STANDING
BOTTOM_HIP = _bottom_hip()


def pose(e):
    """e = 0 standing .. 1 at the bottom. The hips lead backward ("push your
    hips back") and sink evenly, so the knees never run further forward than
    at the bottom."""
    back = 1 - (1 - e) ** 2
    hip = (TOP_HIP[0] + (BOTTOM_HIP[0] - TOP_HIP[0]) * back,
           TOP_HIP[1] + (BOTTOM_HIP[1] - TOP_HIP[1]) * e)
    trunk = TRUNK_LEAN * e
    p = SidePose(root=hip, trunk=trunk, neck=-0.6 * trunk, scale=K)
    p = plant_foot(p, "near", ANKLE)
    p = plant_foot(p, "far", FAR_ANKLE)
    p = place_hand(p, "near", NEAR_HAND, hand_angle=100.0 - trunk)
    return place_hand(p, "far", FAR_HAND, hand_angle=100.0 - trunk)


TIMING = side(0.0, 1.4, 0.2, 1.4)
DURATION = TIMING.out_end + REST


def frame(t, room):
    e = phase(t, TIMING)
    img = room.copy()
    draw_side_figure(img, pose(e), glow_at="near_thigh", glow_k=GLOW_PEAK * e)
    return img.convert("RGB").resize((W, H), Image.LANCZOS)


VIDEOS = [
    VideoSpec(id="squats", exercise_key="squats", position="standing",
              duration=DURATION, sides=(TIMING,), props=frozenset({"chair"}), frame=frame),
]
