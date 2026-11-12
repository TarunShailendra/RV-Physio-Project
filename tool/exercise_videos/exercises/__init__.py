from spec import VideoSpec

from . import (clamshells, diaphragmatic_breathing, leg_circles, leg_scissors, lunges,
               pelvic_bridging, pelvic_rotations, pelvic_tilt, pfmt, quadruped_arm_leg_raise,
               side_leg_raise, single_leg_stretch, squats, straight_leg_raise, wall_squat)

ALL_VIDEOS: list[VideoSpec] = [
    *pelvic_bridging.VIDEOS,
    *pfmt.VIDEOS,
    *diaphragmatic_breathing.VIDEOS,
    *pelvic_tilt.VIDEOS,
    *pelvic_rotations.VIDEOS,
    *straight_leg_raise.VIDEOS,
    *side_leg_raise.VIDEOS,
    *single_leg_stretch.VIDEOS,
    *leg_scissors.VIDEOS,
    *leg_circles.VIDEOS,
    *wall_squat.VIDEOS,
    *quadruped_arm_leg_raise.VIDEOS,
    *clamshells.VIDEOS,
    *lunges.VIDEOS,
    *squats.VIDEOS,
]
