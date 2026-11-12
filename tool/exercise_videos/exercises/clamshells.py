"""Clamshells, lying on the side, seen from the front.

She lies on her side, hips stacked one above the other, knees bent in front
of her and stacked, feet together, head resting on the lower arm and the
upper hand on the hip. Keeping the feet touching, the top knee lifts toward
the ceiling like a clamshell opening, turning about the line from the hip to
the feet, pauses briefly, and lowers slowly. The pelvis, trunk, feet and
lower leg never move (the top hip does not roll back). The outer hip glows
as the knee opens; at the top a green dashed line through both hips shows
them stacked. Unheld loop: rest 0.4 s, open 1.2 s, pause 0.4 s, lower 1.6 s,
rest 0.4 s.
"""
from PIL import Image

from figure_front import (SIDE_CAM, SIDE_HIPS, SIDE_PELVIS_X, add, draw_front_figure, draw_guide,
                          leg, rotate, side_lying, side_room, sub, unit3)
from spec import VideoSpec
from studio import H, W

from ._motion import REST, phase, side

OPEN = 40.0               # degrees the top knee opens: a comfortable clamshell
FOOT = 12.0               # ankle height of the lower foot: the shoe's side on the mat
TOES = (0.95, 0.0, 0.3)   # feet relaxed, in line with the shins
GLOW_PEAK = 0.45

_ANKLE_BOTTOM = (SIDE_PELVIS_X + 236, FOOT, 6.0)
_ANKLE_TOP = (SIDE_PELVIS_X + 236, 3 * FOOT, 6.0)     # the top foot rests on the lower one
_FORWARD = (0.0, 0.0, 1.0)


def legs(e):
    """e: 0 knees together .. 1 open. The top knee turns about its hip-ankle line."""
    hip = SIDE_HIPS["top"]
    pole = rotate(_FORWARD, unit3(sub(_ANKLE_TOP, hip)), -OPEN * e)
    return {"bottom": leg(SIDE_HIPS["bottom"], _ANKLE_BOTTOM, _FORWARD, TOES, shade=1.0),
            "top": leg(hip, _ANKLE_TOP, pole, TOES)}


GLOW_AT = add(SIDE_HIPS["top"], (-4.0, 20.0, -6.0))   # outer hip (gluteus medius), top side
GUIDE = [add(SIDE_HIPS["bottom"], (0, -38, 0)), SIDE_HIPS["bottom"], SIDE_HIPS["top"],
         add(SIDE_HIPS["top"], (0, 52, 0))]

S1 = side(0.0, 1.2, 0.4, 1.6)
DURATION = S1.out_end + REST


def frame(t, room):
    e = phase(t, S1)
    img = side_room(room).copy()
    draw_front_figure(img, side_lying(legs(e)), SIDE_CAM, glow_at=GLOW_AT, glow_k=GLOW_PEAK * e)
    draw_guide(img, SIDE_CAM, GUIDE, max(0.0, min(1.0, (e - 0.85) / 0.15)))
    return img.convert("RGB").resize((W, H), Image.LANCZOS)


VIDEOS = [
    VideoSpec(id="clamshells", exercise_key="clamshells", position=None,
              duration=DURATION, sides=(S1,), props=frozenset(), frame=frame),
]
