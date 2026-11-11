"""Pelvic floor training: the figure sits perfectly still and a soft glow low
between the hips fades in on the squeeze and out on the relax.

Slow (held): rest 0.4 s, squeeze 1.2 s, plateau 0.8 s, relax 1.2 s, rest 0.4 s.
Quick (unheld loop): rest 0.4 s, in 0.3 s, plateau 0.2 s, out 0.3 s, rest 0.4 s.
"""
from PIL import Image

from figure import SIDE_SITTING, SIDE_STANDING, SIDE_SUPINE_KNEES_BENT, draw_side_figure
from spec import SideTiming, VideoSpec
from studio import H, W, blur_sprite, ease, paste_sprite

PF_GLOW = blur_sprite(60, 50, (255, 120, 50), 12)  # smaller than the working-muscle GLOW
GLOW_PEAK = 0.7
SLING_PEAK = 0.8

POSES = {
    "supine": (SIDE_SUPINE_KNEES_BENT, frozenset()),
    "sitting": (SIDE_SITTING, frozenset({"chair"})),
    "standing": (SIDE_STANDING, frozenset({"chair"})),
}


def timing(into, plateau, out, rest=0.4):
    s = SideTiming(rest, rest + into, rest + into + plateau, rest + into + plateau + out)
    return s, s.out_end + rest


def squeeze(t, s):
    """0 relaxed .. 1 fully squeezed, eased in and out of the plateau."""
    if t < s.into_start:
        return 0.0
    if t < s.hold:
        return ease((t - s.into_start) / (s.hold - s.into_start))
    if t < s.out_start:
        return 1.0
    if t < s.out_end:
        return 1 - ease((t - s.out_start) / (s.out_end - s.out_start))
    return 0.0


def make_frame(pose, s):
    def frame(t, room):
        k = squeeze(t, s)
        img = room.copy()
        pts = draw_side_figure(img, pose, highlight_pelvic_floor=k * SLING_PEAK)
        paste_sprite(img, PF_GLOW, pts["pelvic_floor"], k * GLOW_PEAK)
        return img.convert("RGB").resize((W, H), Image.LANCZOS)
    return frame


def make(kind, position, into, plateau, out):
    pose, props = POSES[position]
    s, duration = timing(into, plateau, out)
    return VideoSpec(id=f"pfmt_{kind}_{position}", exercise_key=f"pfmt_{kind}", position=position,
                     duration=duration, sides=(s,), props=props, frame=make_frame(pose, s))


VIDEOS = [make("slow", p, 1.2, 0.8, 1.2) for p in POSES] + \
         [make("quick", p, 0.3, 0.2, 0.3) for p in POSES]
