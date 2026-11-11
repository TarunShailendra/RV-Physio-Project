"""Lunges, standing side-on beside the chair prop, the far hand on its backrest.

The figure faces right with the chair beside her on the far side (she is
drawn in front of it), her far hand on the top of its backrest for balance.
The near foot steps forward; both knees bend, the back knee lowering toward
the floor on the ball of the back foot, the front knee straight over the
front ankle and the upper body tall; she pushes back up through the front
foot and steps back to standing. The back foot's toes never move, the far
hand never leaves the backrest, and the trunk stays upright. The front thigh
glows as she lowers, and a green dashed line marks the front knee over the
ankle at the bottom.

Unheld loop: rest 0.4 s, step 0.9 s, lower 1.0 s, a 0.2 s pause, push up
1.0 s, step back 0.9 s, rest 0.4 s. The into segment is step + lower and the
out segment push up + step back.
"""
import math

from PIL import Image, ImageDraw

from figure import (FLOOR, SHIN, STANDING_SCALE, THIGH, SidePose, draw_side_figure, place_hand,
                    plant_foot, pose_points)
from spec import VideoSpec
from studio import H, W, dashed_line, ease

from ._motion import REST, side

K = STANDING_SCALE
X0 = 524.0                          # standing hip: the far hand reaches the backrest here and at the bottom
ANKLE_Y = FLOOR - 21 * K
STEP = 290.0                        # how far the near foot steps forward
FRONT_THIGH = 12.0                  # degrees below level at the bottom
BACK_TOE = (X0 - 8 * K + 55 * K, ANKLE_Y - 2 * K + 18 * K)   # the back foot's toes stay put
HEEL_UP = (0.0, 15.0, 50.0)         # back heel lift: standing, after the step, at the bottom
FAR_HAND = (591.0, 322.0)           # on top of the backrest
SWING = 16.0                        # px the stepping foot clears the floor
GLOW_PEAK = 0.45

FRONT_ANKLE = (X0 + STEP, ANKLE_Y)
_FRONT_KNEE = (FRONT_ANKLE[0], ANKLE_Y - SHIN * K)
HIPS = (
    (X0, ANKLE_Y - (THIGH + SHIN) * K),                    # standing tall, as SIDE_STANDING
    (X0 + 140.0, 336.0),                                   # split stance, legs nearly straight
    (_FRONT_KNEE[0] - THIGH * K * math.cos(math.radians(FRONT_THIGH)),
     _FRONT_KNEE[1] - THIGH * K * math.sin(math.radians(FRONT_THIGH))),   # bottom
)

STEP_T, LOWER_T, PAUSE = 0.9, 1.0, 0.2
TIMING = side(0.0, STEP_T + LOWER_T, PAUSE, LOWER_T + STEP_T)
DURATION = TIMING.out_end + REST


def _lerp(a, b, k):
    return (a[0] + (b[0] - a[0]) * k, a[1] + (b[1] - a[1]) * k)


def _back_ankle(heel):
    """The back ankle with the heel raised `heel` degrees about the fixed toes."""
    c, s = math.cos(math.radians(heel)), math.sin(math.radians(heel))
    tx, ty = 55 * K, 18 * K                       # ankle -> toe, foot flat
    return (BACK_TOE[0] - (tx * c - ty * s), BACK_TOE[1] - (tx * s + ty * c))


ELBOW_BACK = 14.0     # px the far elbow sits behind the shoulder-to-hand line
ELBOW_AT = 0.53       # the upper arm's share of shoulder -> hand
REACH = 211.0         # shoulder -> hand centre, arm straight, at this scale


def _hold_chair(p):
    """The far hand on the backrest. The chair is beside her, so as she steps
    forward the arm reaches out sideways and back to it: the elbow is pinned
    on the shoulder-to-hand line, a little behind it once the arm has slack,
    and the arm is drawn foreshortened as the reach shortens."""
    sh = pose_points(p)["shoulder"]
    d = math.dist(sh, FAR_HAND)
    mx, my = sh[0] + (FAR_HAND[0] - sh[0]) * ELBOW_AT, sh[1] + (FAR_HAND[1] - sh[1]) * ELBOW_AT
    nx, ny = -(FAR_HAND[1] - sh[1]) / d, (FAR_HAND[0] - sh[0]) / d   # perpendicular, toward the back
    off = ELBOW_BACK * max(0.0, min(1.0, (REACH - d) / 30))
    return place_hand(p, "far", FAR_HAND, hand_angle=100.0, elbow=(mx + nx * off, my + ny * off))


def pose(step, lower):
    """step: 0 feet together .. 1 the near foot planted forward; lower: 0 legs
    nearly straight .. 1 at the bottom (only once the step is done)."""
    if lower > 0:
        hip = _lerp(HIPS[1], HIPS[2], lower)
        heel = HEEL_UP[1] + (HEEL_UP[2] - HEEL_UP[1]) * lower
        front = FRONT_ANKLE
    else:
        hip = _lerp(HIPS[0], HIPS[1], step ** 1.8)     # the foot leads, the hips follow
        heel = HEEL_UP[0] + (HEEL_UP[1] - HEEL_UP[0]) * step
        start = (X0 + 2 * K, ANKLE_Y)
        front = (start[0] + (FRONT_ANKLE[0] - start[0]) * step,
                 ANKLE_Y - SWING * math.sin(math.pi * step))
    p = SidePose(root=hip, trunk=0.0, scale=K, near_elbow=8.0)
    p = plant_foot(p, "near", front)
    p = plant_foot(p, "far", _back_ankle(heel), foot=90.0 + heel)
    return _hold_chair(p)


def stages(t):
    """(step, lower), each 0..1, eased, at time t."""
    s = TIMING
    if t < s.into_start or t >= s.out_end:
        return 0.0, 0.0
    if t < s.hold:
        u = t - s.into_start
        return ease(u / STEP_T), ease((u - STEP_T) / LOWER_T)
    if t < s.out_start:
        return 1.0, 1.0
    u = t - s.out_start
    return 1 - ease((u - LOWER_T) / STEP_T), 1 - ease(u / LOWER_T)


def draw_guide(img, lower, pts):
    """Dashed vertical line through the front knee and ankle, fading in over
    the last 15% of the lowering."""
    a = max(0.0, min(1.0, (lower - 0.85) / 0.15))
    if a <= 0:
        return
    ov = Image.new("RGBA", img.size, (0, 0, 0, 0))
    knee, ankle = pts["near_knee"], pts["near_ankle"]
    x = ankle[0]
    dashed_line(ImageDraw.Draw(ov), [(x, knee[1] - 45), (x, knee[1]), (x, ankle[1]),
                                     (x, FLOOR + 6)], a)
    img.alpha_composite(ov)


def frame(t, room):
    step, lower = stages(t)
    img = room.copy()
    pts = draw_side_figure(img, pose(step, lower), glow_at="near_thigh", glow_k=GLOW_PEAK * lower)
    draw_guide(img, lower, pts)
    return img.convert("RGB").resize((W, H), Image.LANCZOS)


VIDEOS = [
    VideoSpec(id="lunges", exercise_key="lunges", position="standing",
              duration=DURATION, sides=(TIMING,), props=frozenset({"chair"}), frame=frame),
]
