"""Quadruped arm and leg raise ("bird dog"), on hands and knees on the mat.

Hands under the shoulders, knees under the hips, back flat. With the lower
belly glowing (the gentle squeeze), the near arm reaches straight forward
while the opposite (far) leg straightens straight back: the knee straightens
first, the toes sliding back just clear of the mat, and then the straight leg
lifts to hip height as the arm lifts to shoulder height. Hold, a green dashed
line along the flat back and out along the extended leg; lower
the same way; then the far arm and the near leg. The trunk, hips and head
never move, and the supporting hand and knee stay planted. Two held sides,
each rest 0.4 s, reach 1.5 s, plateau 0.8 s, return 1.5 s, rest 0.4 s.
"""
import math
from dataclasses import replace

from PIL import Image, ImageDraw

from figure import SIDE_QUADRUPED, draw_side_figure, lerp_pose, place_hand, plant_foot, pose_points
from spec import VideoSpec
from studio import H, W, dashed_line

from ._motion import REST, phase, side

BASE = SIDE_QUADRUPED
SLIDE = 0.55          # share of the movement spent straightening (before lifting)
LOW = 25.0            # degrees below level the straight leg (and arm) points before lifting
POINT = 70.0          # ankle: toes pointed, as in the reach-out reference pose
HAND_LIFT = 14.0      # px the hand rises off the mat early in the reach, clear of it
GLOW_PEAK = 0.4


def _limbs(arm, leg, lift):
    """BASE with `arm` reaching forward and `leg` straight back, both `lift`
    from LOW degrees below level (0) to level (1)."""
    low = LOW * (1 - lift)
    return replace(BASE, **{
        arm + "_shoulder": 180.0 - low, arm + "_elbow": 0.0, arm + "_wrist": 0.0,
        arm + "_upper_arm": 1.0, arm + "_forearm": 1.0,
        leg + "_hip": low, leg + "_knee": 0.0, leg + "_ankle": POINT,
    })


def _lerp(a, b, k):
    return (a[0] + (b[0] - a[0]) * k, a[1] + (b[1] - a[1]) * k)


def _foot_dir(p, leg):
    """The leg's foot direction (plant_foot's `foot`) in pose p."""
    hip = getattr(p, leg + "_hip")
    knee = getattr(p, leg + "_knee")
    shin = p.trunk + 180 - hip + knee
    return shin - 90 + getattr(p, leg + "_ankle")


def pose(arm, leg, e):
    """e: 0 on hands and knees .. 1 arm and leg level."""
    straight = _limbs(arm, leg, 0.0)
    if e >= SLIDE:
        return lerp_pose(straight, _limbs(arm, leg, 1.0), (e - SLIDE) / (1 - SLIDE))
    k = e / SLIDE
    p = lerp_pose(BASE, straight, k)
    # the hand lifts off the mat and travels forward and up while the elbow unfolds
    b, s = pose_points(BASE), pose_points(straight)
    hand = _lerp(b[arm + "_hand"], s[arm + "_hand"], k)
    hand = (hand[0], hand[1] - HAND_LIFT * math.sin(math.pi * k))
    p = place_hand(p, arm, hand, hand_angle=90.0 + LOW * k,
                   elbow=_lerp(b[arm + "_elbow"], s[arm + "_elbow"], k))
    # the leg straightens with its ankle on a straight line back, toes just clear of the mat
    ankle = _lerp(b[leg + "_ankle"], s[leg + "_ankle"], k)
    foot = _foot_dir(BASE, leg) + (_foot_dir(straight, leg) - _foot_dir(BASE, leg)) * k
    return plant_foot(p, leg, ankle, foot=foot)


S1 = side(0.0, 1.5, 0.8, 1.5)
S2 = side(S1.out_end + REST, 1.5, 0.8, 1.5)
DURATION = S2.out_end + REST


def draw_guide(img, e, pts, leg):
    """Dashed line along the flat back, from just past the shoulder out along
    the extended leg (stopping short of the head), fading in over the top
    15% of the movement."""
    a = max(0.0, min(1.0, (e - 0.85) / 0.15))
    if a <= 0:
        return
    sh, hp = pts["shoulder"], pts["pelvis"]
    y = (sh[1] + hp[1]) / 2
    ov = Image.new("RGBA", img.size, (0, 0, 0, 0))
    dashed_line(ImageDraw.Draw(ov), [(pts[leg + "_ankle"][0] - 20, y), (hp[0], y), (sh[0], y),
                                     (sh[0] + 25, y)], a)
    img.alpha_composite(ov)


def frame(t, room):
    e1, e2 = phase(t, S1), phase(t, S2)
    arm, leg, e = ("near", "far", e1) if e1 > 0 else ("far", "near", e2)
    img = room.copy()
    # the belly squeezes first, then the arm and leg move
    pts = draw_side_figure(img, pose(arm, leg, e), glow_at="belly", glow_k=GLOW_PEAK * min(1.0, 2 * e))
    draw_guide(img, e, pts, leg)
    return img.convert("RGB").resize((W, H), Image.LANCZOS)


VIDEOS = [
    VideoSpec(id="quadruped_arm_leg_raise", exercise_key="quadruped_arm_leg_raise", position=None,
              duration=DURATION, sides=(S1, S2), props=frozenset(), frame=frame),
]
