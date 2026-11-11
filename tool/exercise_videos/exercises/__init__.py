from spec import VideoSpec

from . import (diaphragmatic_breathing, leg_circles, leg_scissors, lunges, pelvic_bridging,
               pelvic_tilt, pfmt, quadruped_arm_leg_raise, single_leg_stretch, squats,
               straight_leg_raise, wall_squat)

ALL_VIDEOS: list[VideoSpec] = [
    *pelvic_bridging.VIDEOS,
    *pfmt.VIDEOS,
    *diaphragmatic_breathing.VIDEOS,
    *pelvic_tilt.VIDEOS,
    *straight_leg_raise.VIDEOS,
    *single_leg_stretch.VIDEOS,
    *leg_scissors.VIDEOS,
    *leg_circles.VIDEOS,
    *wall_squat.VIDEOS,
    *quadruped_arm_leg_raise.VIDEOS,
    *lunges.VIDEOS,
    *squats.VIDEOS,
]
