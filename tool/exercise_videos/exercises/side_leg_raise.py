"""Side leg raise, lying on the side, seen from the front.

She lies on her side, hips stacked, the bottom leg slightly bent forward for
balance and the top leg straight, head resting on the lower arm and the
upper hand on the hip. The straight top leg lifts straight up toward the
ceiling, staying in line with the body (it neither comes forward nor goes
back), holds, and lowers slowly. The pelvis, trunk and bottom leg never move
(the top hip does not roll back). The outer hip and thigh glow as the leg
rises; at the top a green dashed line through both hips shows them stacked.
Held: rest 0.4 s, lift 1.4 s, plateau 0.8 s, lower 1.5 s, rest 0.4 s.
"""
import math

from PIL import Image

from figure import SHIN, THIGH
from figure_front import (SIDE_CAM, SIDE_HIPS, SIDE_PELVIS_X, add, draw_front_figure, draw_guide,
                          leg, mul, side_lying, side_room)
from spec import VideoSpec
from studio import H, W

from ._motion import REST, phase, side

FOOT = 12.0                     # ankle height of a foot whose side rests on the mat
REST_ANGLE = math.degrees(math.asin((FOOT + 2 - SIDE_HIPS["top"][1]) / (THIGH + SHIN)))
LIFT_ANGLE = 35.0               # degrees above the line of the body at the top
GLOW_PEAK = 0.45

_FORWARD = (0.0, 0.0, 1.0)
BOTTOM = leg(SIDE_HIPS["bottom"], (SIDE_PELVIS_X + 300, FOOT, 100.0), _FORWARD, (0.7, 0.0, 0.7),
             shade=1.0)


def top_leg(e):
    """The straight top leg and its direction, e: 0 resting .. 1 lifted, in
    the plane of the body."""
    a = math.radians(REST_ANGLE + (LIFT_ANGLE - REST_ANGLE) * e)
    d = (math.cos(a), math.sin(a), 0.0)
    return leg(SIDE_HIPS["top"], add(SIDE_HIPS["top"], mul(d, THIGH + SHIN)), _FORWARD, _FORWARD), d


GUIDE = [add(SIDE_HIPS["bottom"], (0, -38, 0)), SIDE_HIPS["bottom"], SIDE_HIPS["top"],
         add(SIDE_HIPS["top"], (0, 52, 0))]

S1 = side(0.0, 1.4, 0.8, 1.5)
DURATION = S1.out_end + REST


def frame(t, room):
    e = phase(t, S1)
    top, d = top_leg(e)
    outer = (-d[1], d[0], 0.0)              # the side of the thigh facing the ceiling
    glow = add(add(SIDE_HIPS["top"], mul(d, 30)), mul(outer, 16))
    img = side_room(room).copy()
    draw_front_figure(img, side_lying({"bottom": BOTTOM, "top": top}), SIDE_CAM,
                      glow_at=glow, glow_k=GLOW_PEAK * e)
    draw_guide(img, SIDE_CAM, GUIDE, max(0.0, min(1.0, (e - 0.85) / 0.15)))
    return img.convert("RGB").resize((W, H), Image.LANCZOS)


VIDEOS = [
    VideoSpec(id="side_leg_raise", exercise_key="side_leg_raise", position=None,
              duration=DURATION, sides=(S1,), props=frozenset(), frame=frame),
]
