"""Diaphragmatic breathing, lying on the back with knees bent.

Near hand on the chest, far hand on the belly. The belly profile rises over
3 s and falls over 4 s; the chest outline never moves. Unheld loop:
rest 0.4 s, in 3.0 s, out 4.0 s, rest 0.4 s.
"""
from dataclasses import replace

from PIL import Image

from figure import SIDE_SUPINE_KNEES_BENT, draw_side_figure, hand_on
from spec import SideTiming, VideoSpec
from studio import H, W, ease

BELLY_RISE = 10  # px the belly pushes out at full breath in
REST, IN, OUT = 0.4, 3.0, 4.0
DURATION = REST + IN + OUT + REST
TIMING = SideTiming(REST, REST + IN, REST + IN, REST + IN + OUT)


def breath(t):
    if t < TIMING.into_start:
        return 0.0
    if t < TIMING.hold:
        return ease((t - TIMING.into_start) / IN)
    if t < TIMING.out_end:
        return 1 - ease((t - TIMING.out_start) / OUT)
    return 0.0


def frame(t, room):
    p = replace(SIDE_SUPINE_KNEES_BENT, belly=BELLY_RISE * breath(t))
    p = hand_on(hand_on(p, "near", "chest"), "far", "belly")  # the far hand rides the belly
    img = room.copy()
    draw_side_figure(img, p)
    return img.convert("RGB").resize((W, H), Image.LANCZOS)


VIDEOS = [
    VideoSpec(id="diaphragmatic_breathing", exercise_key="diaphragmatic_breathing",
              position="supine", duration=DURATION, sides=(TIMING,),
              props=frozenset(), frame=frame),
]
