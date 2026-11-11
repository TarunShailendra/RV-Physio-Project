from spec import VideoSpec

from . import (diaphragmatic_breathing, leg_circles, leg_scissors, pelvic_bridging, pelvic_tilt,
               pfmt, single_leg_stretch, straight_leg_raise)

ALL_VIDEOS: list[VideoSpec] = [
    *pelvic_bridging.VIDEOS,
    *pfmt.VIDEOS,
    *diaphragmatic_breathing.VIDEOS,
    *pelvic_tilt.VIDEOS,
    *straight_leg_raise.VIDEOS,
    *single_leg_stretch.VIDEOS,
    *leg_scissors.VIDEOS,
    *leg_circles.VIDEOS,
]
