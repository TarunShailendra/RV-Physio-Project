"""Leg scissors, lying on the back.

Both legs point straight up. The near leg lowers toward the mat, knee
straight, and returns; then the far leg. The trunk stays flat on the mat
throughout, the belly glowing as a leg goes down. Unheld loop of two sides,
each rest 0.4 s, lower 1.3 s, pause 0.2 s, raise 1.3 s, rest 0.4 s.
"""
from dataclasses import replace

from PIL import Image

from figure import SIDE_SUPINE_KNEES_BENT, draw_side_figure, lerp_pose
from spec import VideoSpec
from studio import H, W

from ._motion import REST, phase, side

ROOT = (570.0, 560.0)     # far enough left that the feet pass clear of the wall clock
UP_HIP, LOW_HIP = 90.0, 40.0    # straight up; lowered to 40 degrees above the mat
FAR_SPLAY = 4.0                 # the far leg leans a touch toward the feet so both legs show
POINT = 0.0                     # feet flexed, soles to the ceiling (pointed toes would brush the clock)
GLOW_PEAK = 0.4

UP = replace(SIDE_SUPINE_KNEES_BENT, root=ROOT, near_hip=UP_HIP, near_knee=0.0, near_ankle=POINT,
             far_hip=UP_HIP - FAR_SPLAY, far_knee=0.0, far_ankle=POINT)
NEAR_DOWN = replace(UP, near_hip=LOW_HIP)
FAR_DOWN = replace(UP, far_hip=LOW_HIP)

S1 = side(0.0, 1.3, 0.2, 1.3)
S2 = side(S1.out_end + REST, 1.3, 0.2, 1.3)
DURATION = S2.out_end + REST


def frame(t, room):
    e1, e2 = phase(t, S1), phase(t, S2)
    p = lerp_pose(UP, NEAR_DOWN, e1) if e1 > 0 else lerp_pose(UP, FAR_DOWN, e2)
    img = room.copy()
    draw_side_figure(img, p, glow_at="belly", glow_k=GLOW_PEAK * max(e1, e2))
    return img.convert("RGB").resize((W, H), Image.LANCZOS)


VIDEOS = [
    VideoSpec(id="leg_scissors", exercise_key="leg_scissors", position="supine",
              duration=DURATION, sides=(S1, S2), props=frozenset(), frame=frame),
]
