"""Wall squat, standing side-on with the back against the wall prop.

The figure faces left, her back flat against the wall and her feet a small
step forward of it. She slides straight down the wall, the trunk upright and
touching it throughout, until the knees are bent about 60 degrees with the
shins vertical (knees over ankles); hold; slide back up. The feet stay
planted. The thighs glow while she is down, and a green dashed line marks the
knee straight above the ankle at the hold. Held: rest 0.4 s, down 1.5 s,
plateau 0.8 s, up 1.5 s, rest 0.4 s.
"""
import math

from PIL import Image, ImageDraw

from figure import (FLOOR, SHIN, STANDING_SCALE, THIGH, SidePose, draw_side_figure, hand_on,
                    plant_foot)
from spec import VideoSpec
from studio import H, W, dashed_line

from ._motion import REST, phase, side

K = STANDING_SCALE
WALL_X = 930.0
ROOT_X = WALL_X - 27 * K - 1          # the glutes touch the wall
ANKLE_Y = FLOOR - 21 * K              # soles on the floor line
KNEE_BEND = 60.0                      # degrees at the hold, shins vertical
START_BEND = 12.0                     # knees soft at the top
_T, _S = THIGH * K, SHIN * K
ANKLE_X = ROOT_X - _T * math.sin(math.radians(KNEE_BEND))   # knee right above the ankle at the hold
FAR_DX = 8 * K                        # the far foot sits a little behind, as in SIDE_STANDING
GLOW_PEAK = 0.45


def _root_y(e):
    """Hip height: knees soft at the top, knees over ankles at the bottom."""
    reach = math.sqrt(_T ** 2 + _S ** 2 + 2 * _T * _S * math.cos(math.radians(START_BEND)))
    top = ANKLE_Y - math.sqrt(reach ** 2 - (ROOT_X - ANKLE_X) ** 2)
    bottom = ANKLE_Y - _S - _T * math.cos(math.radians(KNEE_BEND))
    return top + (bottom - top) * e


def pose(e):
    p = SidePose(root=(ROOT_X, _root_y(e)), trunk=0.0, scale=K, facing=-1,
                 near_elbow=8.0, far_elbow=8.0, far_shoulder=-4.0)
    p = plant_foot(p, "near", (ANKLE_X, ANKLE_Y))
    p = plant_foot(p, "far", (ANKLE_X + FAR_DX, ANKLE_Y - 2 * K))
    return hand_on(hand_on(p, "near", "thigh"), "far", "thigh")


TIMING = side(0.0, 1.5, 0.8, 1.5)
DURATION = TIMING.out_end + REST


def draw_guide(img, e, pts):
    """Dashed vertical line through knee and ankle, fading in over the top 15% of the descent."""
    a = max(0.0, min(1.0, (e - 0.85) / 0.15))
    if a <= 0:
        return
    ov = Image.new("RGBA", img.size, (0, 0, 0, 0))
    knee, ankle = pts["near_knee"], pts["near_ankle"]
    x = ankle[0]
    dashed_line(ImageDraw.Draw(ov), [(x, knee[1] - 45), (x, knee[1]), (x, ankle[1]),
                                     (x, FLOOR + 6)], a)
    img.alpha_composite(ov)


def frame(t, room):
    e = phase(t, TIMING)
    img = room.copy()
    pts = draw_side_figure(img, pose(e), glow_at="near_thigh", glow_k=GLOW_PEAK * e)
    draw_guide(img, e, pts)
    return img.convert("RGB").resize((W, H), Image.LANCZOS)


VIDEOS = [
    VideoSpec(id="wall_squat", exercise_key="wall_squat", position="standing",
              duration=DURATION, sides=(TIMING,), props=frozenset({"wall"}), frame=frame),
]
