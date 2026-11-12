"""Data types shared by the exercise video modules and the renderer."""
from dataclasses import dataclass
from typing import Callable

from PIL import Image


@dataclass(frozen=True)
class SideTiming:
    """Seconds within one video: the movement into the hold runs
    into_start..hold, the hold plateau hold..out_start, and the movement out
    of it out_start..out_end."""
    into_start: float
    hold: float
    out_start: float
    out_end: float


@dataclass(frozen=True)
class VideoSpec:
    id: str
    exercise_key: str
    position: str | None  # an ExercisePosition name: supine, sitting, standing
    duration: float
    sides: tuple[SideTiming, ...]
    props: frozenset[str]
    # frame(t, room) draws the figure at time t on a copy of room and returns
    # the full-resolution RGB frame.
    frame: Callable[[float, Image.Image], Image.Image]
