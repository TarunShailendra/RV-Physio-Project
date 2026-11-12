"""Pelvic rotations, lying on the back, seen from her feet.

Knees bent and together, feet flat and together, arms spread wide on the
mat. Both knees lower together to the picture's left as far as is
comfortable (moderately, not to the floor), the pelvis turning a little with
them, hold, and come slowly back; then the same to the right. The feet stay
planted; the shoulders, arms and head stay flat on the mat. The waist (the
obliques, on the side away from the knees) glows through the turn; at the
hold a green dashed line across the shoulders shows them level on the
floor. The camera stands a little round to her left so the bend of the
knees shows. Two held sides, each rest 0.4 s, lower 1.5 s, plateau 0.8 s,
return 1.5 s, rest 0.4 s.
"""
from PIL import Image

from figure import TORSO
from figure_front import (FEET_CAM, draw_front_figure, draw_guide, feet_room, knees_bent, supine,
                          supine_layers)
from spec import VideoSpec
from studio import H, W

from ._motion import REST, phase, side

DROP = 35.0               # degrees the knees lower to each side
GLOW_PEAK = 0.4
GLOW_F, GLOW_SIDE = 0.66, 0.6   # the waist, toward the side away from the knees

S1 = side(0.0, 1.5, 0.8, 1.5)
S2 = side(S1.out_end + REST, 1.5, 0.8, 1.5)
DURATION = S2.out_end + REST

_SHOULDER_Y, _SHOULDER_Z = 30.0, -TORSO + 4
GUIDE = [(x, _SHOULDER_Y, _SHOULDER_Z) for x in (-112.0, -30.0, 30.0, 112.0)]


def frame(t, room):
    # room (make_room's side-on gym) is not used: this camera has its own room
    e1, e2 = phase(t, S1), phase(t, S2)
    drop, e = (DROP * e1, e1) if e1 > 0 else (-DROP * e2, e2)
    legs, roll = knees_bent(drop)
    body = supine(legs, roll, supine_layers(drop))
    img = feet_room().copy()
    # the waist (obliques) on the side away from the knees
    away = 1.0 if drop > 0 else -1.0          # trunk.across is the picture's right
    glow = body.trunk.surface(GLOW_F, GLOW_SIDE * away)
    draw_front_figure(img, body, FEET_CAM, glow_at=glow, glow_k=GLOW_PEAK * e)
    draw_guide(img, FEET_CAM, GUIDE, max(0.0, min(1.0, (e - 0.85) / 0.15)))
    return img.convert("RGB").resize((W, H), Image.LANCZOS)


VIDEOS = [
    VideoSpec(id="pelvic_rotations", exercise_key="pelvic_rotations", position="supine",
              duration=DURATION, sides=(S1, S2), props=frozenset(), frame=frame),
]
