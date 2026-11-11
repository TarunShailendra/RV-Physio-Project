"""Pelvic tilt, lying on the back with knees bent and feet flat.

The pelvis rolls back a few degrees: the hollow under the lower back closes
onto the mat while the lower belly draws in under a soft glow. The hips, legs
and shoulders stay where they are. The hands rest on the belly and chest, off
the floor, so the lower back's profile can be seen. Held: rest 0.4 s, tilt
1.5 s, plateau 0.8 s, release 1.5 s, rest 0.4 s.
"""
from dataclasses import replace

from PIL import Image

from figure import SIDE_SUPINE_KNEES_BENT, draw_side_figure, hand_on, lerp_pose
from spec import VideoSpec
from studio import H, W

from ._motion import REST, phase, side

# Relaxed: the natural hollow of the lower back, a gap above the mat.
RELAXED = replace(SIDE_SUPINE_KNEES_BENT, pelvis=-14.0, lumbar=-8.0)
# Tilted: the pelvis rolled back, the lower back flat on the mat.
TILTED = replace(SIDE_SUPINE_KNEES_BENT, pelvis=4.0, lumbar=0.0)
GLOW_PEAK = 0.45

TIMING = side(0.0, 1.5, 0.8, 1.5)
DURATION = TIMING.out_end + REST


def pose(e):
    p = lerp_pose(RELAXED, TILTED, e)
    return hand_on(hand_on(p, "near", "belly"), "far", "chest")


def frame(t, room):
    e = phase(t, TIMING)
    img = room.copy()
    draw_side_figure(img, pose(e), glow_at="belly", glow_k=GLOW_PEAK * e)
    return img.convert("RGB").resize((W, H), Image.LANCZOS)


VIDEOS = [
    VideoSpec(id="pelvic_tilt", exercise_key="pelvic_tilt", position="supine",
              duration=DURATION, sides=(TIMING,), props=frozenset(), frame=frame),
]
