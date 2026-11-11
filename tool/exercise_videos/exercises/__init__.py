from spec import VideoSpec

from . import diaphragmatic_breathing, pelvic_bridging, pfmt

ALL_VIDEOS: list[VideoSpec] = [
    *pelvic_bridging.VIDEOS,
    *pfmt.VIDEOS,
    *diaphragmatic_breathing.VIDEOS,
]
