"""Straight leg raise, lying on the back.

The far knee is bent with its foot flat; the near leg lies straight on the
mat. With the thigh glowing, the near leg lifts, knee locked straight, until
its ankle is level with the bent knee, holds there (a green dashed line marks
the knee's height), and lowers. Nothing else moves. Held: rest 0.4 s, lift
1.5 s, plateau 0.8 s, lower 1.5 s, rest 0.4 s.

The figure lies further left than the knees-bent rest pose so that the
straight leg's heel rests on the mat.
"""
import math
from dataclasses import replace

from PIL import Image, ImageDraw

from figure import SIDE_SUPINE_KNEES_BENT, THIGH, SHIN, draw_side_figure, plant_foot, pose_points
from spec import VideoSpec
from studio import H, W, dashed_line

from ._motion import REST, phase, side

ROOT = (548.0, 560.0)
FAR_ANKLE = (ROOT[0] + 166, 564)          # where the bent leg's foot sits, as in the rest pose
LYING_HIP = -1.2                           # the straight leg tips down so its heel rests on the mat
GLOW_PEAK = 0.45


def _base():
    p = replace(SIDE_SUPINE_KNEES_BENT, root=ROOT, near_knee=0.0, near_ankle=0.0, near_hip=LYING_HIP)
    return plant_foot(p, "far", FAR_ANKLE)


BASE = _base()
FAR_KNEE = pose_points(BASE)["far_knee"]
# Raised: the near ankle level with the bent knee, and no higher.
RAISED_HIP = math.degrees(math.asin((ROOT[1] - FAR_KNEE[1]) / (THIGH + SHIN)))

TIMING = side(0.0, 1.5, 0.8, 1.5)
DURATION = TIMING.out_end + REST


def pose(e):
    return replace(BASE, near_hip=LYING_HIP + (RAISED_HIP - LYING_HIP) * e)


def draw_guide(img, e, ankle):
    """Dashed line at the bent knee's height, from the knee to the raised ankle,
    fading in over the top 15% of the lift."""
    a = max(0.0, min(1.0, (e - 0.85) / 0.15))
    if a <= 0:
        return
    ov = Image.new("RGBA", img.size, (0, 0, 0, 0))
    y = FAR_KNEE[1]
    dashed_line(ImageDraw.Draw(ov), [(FAR_KNEE[0] - 40, y), FAR_KNEE, (ankle[0], y),
                                     (ankle[0] + 45, y)], a)
    img.alpha_composite(ov)


def frame(t, room):
    e = phase(t, TIMING)
    img = room.copy()
    # the thigh tightens first, then lifts
    pts = draw_side_figure(img, pose(e), glow_at="near_thigh", glow_k=GLOW_PEAK * min(1.0, 2 * e))
    draw_guide(img, e, pts["near_ankle"])
    return img.convert("RGB").resize((W, H), Image.LANCZOS)


VIDEOS = [
    VideoSpec(id="straight_leg_raise", exercise_key="straight_leg_raise", position="supine",
              duration=DURATION, sides=(TIMING,), props=frozenset(), frame=frame),
]
