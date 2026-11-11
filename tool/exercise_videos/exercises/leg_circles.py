"""Leg circles, lying on the back.

The far knee is bent with its foot flat on the mat; the near leg points
straight up. Keeping the leg straight, its ankle traces one slow, small
circle, seen in slight perspective as an ellipse 40 x 16 px: the leg sways
toward the head and the feet and, as it tips toward and away from the camera,
looks a little shorter. The hips, trunk and bent leg do not move; the belly
glows softly through the circle. Unheld loop: rest 0.4 s, circle 3.0 s,
rest 0.4 s.
"""
import math
from dataclasses import replace

from PIL import Image

from figure import SHIN, SIDE_SUPINE_KNEES_BENT, THIGH, draw_side_figure, plant_foot
from spec import VideoSpec
from studio import H, W, ease

from ._motion import REST, side

ROOT = (590.0, 560.0)
LEG = THIGH + SHIN
RX, RY = 20.0, 8.0          # the ankle's ellipse radii, screen px
# The ellipse's top point is the leg straight up at full length.
CENTRE = (ROOT[0], ROOT[1] - LEG + RY)
GLOW_PEAK = 0.35


def _base():
    p = replace(SIDE_SUPINE_KNEES_BENT, root=ROOT, near_hip=90.0, near_knee=0.0, near_ankle=30.0)
    return plant_foot(p, "far", (ROOT[0] + 166, 564))


BASE = _base()

TIMING = side(0.0, 1.5, 0.0, 1.5)     # into = first half of the circle, out = second half
DURATION = TIMING.out_end + REST


def progress(t):
    """0..1 round the circle, easing out of and back into the rest pose."""
    return ease((t - TIMING.into_start) / (TIMING.out_end - TIMING.into_start))


def pose(u):
    a = -math.pi / 2 + 2 * math.pi * u           # starts and ends at the top of the ellipse
    ankle = (CENTRE[0] + RX * math.cos(a), CENTRE[1] + RY * math.sin(a))
    dx, dy = ankle[0] - ROOT[0], ankle[1] - ROOT[1]
    lean = math.degrees(math.atan2(dx, -dy))      # clockwise from straight up
    return replace(BASE, near_hip=90.0 - lean, near_leg=math.hypot(dx, dy) / LEG)


def frame(t, room):
    u = progress(t)
    img = room.copy()
    draw_side_figure(img, pose(u), glow_at="belly", glow_k=GLOW_PEAK * math.sin(math.pi * u))
    return img.convert("RGB").resize((W, H), Image.LANCZOS)


VIDEOS = [
    VideoSpec(id="leg_circles", exercise_key="leg_circles", position="supine",
              duration=DURATION, sides=(TIMING,), props=frozenset(), frame=frame),
]
