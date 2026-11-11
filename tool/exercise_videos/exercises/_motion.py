"""Timeline helpers shared by the exercise modules."""
from spec import SideTiming
from studio import ease

REST = 0.4  # still frames before and after each side


def side(start, into, plateau, out):
    """A side starting at `start` (its leading rest included): rest, into,
    plateau, out. The trailing rest is the next side's (or the video's) to add."""
    s0 = start + REST
    return SideTiming(s0, s0 + into, s0 + into + plateau, s0 + into + plateau + out)


def phase(t, s):
    """0 at the start pose .. 1 at the hold pose, eased in and out of the plateau."""
    if t < s.into_start:
        return 0.0
    if t < s.hold:
        return ease((t - s.into_start) / (s.hold - s.into_start))
    if t < s.out_start:
        return 1.0
    if t < s.out_end:
        return 1 - ease((t - s.out_start) / (s.out_end - s.out_start))
    return 0.0
