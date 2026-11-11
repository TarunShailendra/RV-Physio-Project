"""Render the exercise demonstration videos and their Dart timing table.

    python tool/exercise_videos/render.py [ID ...] [--preview] [--props]

Always rewrites lib/features/exercise/videos/exercise_videos.g.dart from
ALL_VIDEOS. Renders the named ids (all if none) to assets/videos/<id>.mp4.
--preview renders only an 8-frame key-frame strip per video to
build/exercise_videos/<id>.png. --props saves a preview of the room with each
prop (build/exercise_videos/_room_props.png).
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

from exercises import ALL_VIDEOS  # noqa: E402
from spec import VideoSpec  # noqa: E402
import studio  # noqa: E402

REPO = HERE.parents[1]
VIDEO_DIR = REPO / "assets" / "videos"
PREVIEW_DIR = REPO / "build" / "exercise_videos"
DART_FILE = REPO / "lib" / "features" / "exercise" / "videos" / "exercise_videos.g.dart"
LOOP_TOLERANCE = 2.0  # mean absolute pixel difference between first and last frame


def frame_count(spec: VideoSpec) -> int:
    return round(spec.duration * studio.FPS)


def ms(seconds: float) -> int:
    return round(seconds * 1000)


def dart_source(videos: list[VideoSpec]) -> str:
    out = [
        "// GENERATED FILE - DO NOT EDIT BY HAND.",
        "// Written by tool/exercise_videos/render.py from the video specs.",
        "",
        "import '../models/protocol.dart';",
        "import 'exercise_video.dart';",
        "",
        "const Map<String, ExerciseVideo> exerciseVideos = {",
    ]
    for v in videos:
        position = "null" if v.position is None else "ExercisePosition." + v.position
        out += [
            f"  '{v.id}': ExerciseVideo(",
            f"    id: '{v.id}',",
            f"    exerciseKey: '{v.exercise_key}',",
            f"    position: {position},",
            f"    asset: 'assets/videos/{v.id}.mp4',",
            f"    durationMs: {ms(v.duration)},",
            "    sides: [",
        ]
        for s in v.sides:
            out += [
                "      VideoSide(",
                f"        intoStartMs: {ms(s.into_start)},",
                f"        holdMs: {ms(s.hold)},",
                f"        outStartMs: {ms(s.out_start)},",
                f"        outEndMs: {ms(s.out_end)},",
                "      ),",
            ]
        out += ["    ],", "  ),"]
    out += ["};", ""]
    return "\n".join(out)


def write_dart(videos: list[VideoSpec]) -> None:
    DART_FILE.parent.mkdir(parents=True, exist_ok=True)
    DART_FILE.write_text(dart_source(videos), encoding="utf-8", newline="\n")


def mean_abs_diff(a: Image.Image, b: Image.Image) -> float:
    return float(np.abs(np.asarray(a, dtype=np.float32) - np.asarray(b, dtype=np.float32)).mean())


def render_video(spec: VideoSpec) -> None:
    room = studio.make_room(spec.props)
    n = frame_count(spec)
    ends: list[Image.Image] = []

    def frames():
        for i in range(n):
            fr = spec.frame(i / studio.FPS, room)
            if i == 0 or i == n - 1:
                ends.append(fr)
            yield fr

    written = studio.encode(frames(), VIDEO_DIR / f"{spec.id}.mp4")
    print(f"{spec.id}: frames {written}")
    assert written == n, f"{spec.id}: wrote {written} frames, expected {n}"
    diff = mean_abs_diff(ends[0], ends[-1])
    assert diff < LOOP_TOLERANCE, f"{spec.id}: loop seam {diff:.2f} >= {LOOP_TOLERANCE}"


def render_preview(spec: VideoSpec) -> None:
    room = studio.make_room(spec.props)
    last = (frame_count(spec) - 1) / studio.FPS
    tw, th = studio.W // 3, studio.H // 3
    sheet = Image.new("RGB", (tw * 4, th * 2))
    for i in range(8):
        fr = spec.frame(last * i / 7, room).resize((tw, th), Image.LANCZOS)
        sheet.paste(fr, ((i % 4) * tw, (i // 4) * th))
    PREVIEW_DIR.mkdir(parents=True, exist_ok=True)
    out = PREVIEW_DIR / f"{spec.id}.png"
    sheet.save(out)
    print("preview", out)


def render_props_preview() -> None:
    tw, th = studio.W // 2, studio.H // 2
    sets = [frozenset(), frozenset({"wall"}), frozenset({"chair"}), frozenset({"wall", "chair"})]
    sheet = Image.new("RGB", (tw * 2, th * 2))
    for i, props in enumerate(sets):
        room = studio.make_room(props).convert("RGB").resize((tw, th), Image.LANCZOS)
        sheet.paste(room, ((i % 2) * tw, (i // 2) * th))
    PREVIEW_DIR.mkdir(parents=True, exist_ok=True)
    out = PREVIEW_DIR / "_room_props.png"
    sheet.save(out)
    print("preview", out)


def main(argv: list[str]) -> int:
    flags = {a for a in argv if a.startswith("--")}
    ids = [a for a in argv if not a.startswith("--")]
    write_dart(ALL_VIDEOS)
    if "--props" in flags:
        render_props_preview()
    known = {v.id: v for v in ALL_VIDEOS}
    unknown = [i for i in ids if i not in known]
    if unknown:
        print("unknown video id:", ", ".join(unknown), file=sys.stderr)
        return 2
    chosen = [known[i] for i in ids] if ids else list(ALL_VIDEOS)
    if "--props" in flags and not ids and "--preview" not in flags:
        return 0
    for spec in chosen:
        if "--preview" in flags:
            render_preview(spec)
        else:
            render_video(spec)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
