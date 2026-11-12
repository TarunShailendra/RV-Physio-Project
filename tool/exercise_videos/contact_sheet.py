"""Build a contact sheet of every exercise video for review.

    python tool/exercise_videos/contact_sheet.py

Reads frames from the encoded assets/videos/<id>.mp4 files (not the render
code) at times taken from ALL_VIDEOS: start, mid-way into the hold, the hold,
mid-way out, the last frame, and the second side's hold for two-sided videos.
Writes build/exercise_videos/contact_sheet.png plus contact_sheet_1..N.png
parts (each short enough to read on a laptop screen).
"""
import sys
from pathlib import Path

import cv2
from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

from exercises import ALL_VIDEOS  # noqa: E402

REPO = HERE.parents[1]
VIDEO_DIR = REPO / "assets" / "videos"
OUT_DIR = REPO / "build" / "exercise_videos"

COLUMNS = ["start", "moving in", "hold", "moving out", "end", "side 2 hold"]
FRAME_W, FRAME_H = 320, 180
GAP = 6
LABEL_W = 230
HEADER_H = 34
ROWS_PER_PART = 7
BG = (255, 255, 255)
INK = (30, 30, 30)


def font(size: int):
    for name in ("segoeui.ttf", "arial.ttf"):
        try:
            return ImageFont.truetype("C:/Windows/Fonts/" + name, size)
        except OSError:
            pass
    try:
        return ImageFont.truetype("DejaVuSans.ttf", size)
    except OSError:
        return ImageFont.load_default()


def frame_times(spec) -> list[float | None]:
    s = spec.sides[0]
    last = spec.duration - 1.0 / 30
    times = [
        0.0,
        (s.into_start + s.hold) / 2,
        (s.hold + s.out_start) / 2,
        (s.out_start + s.out_end) / 2,
        last,
        None,
    ]
    if len(spec.sides) > 1:
        t = spec.sides[1]
        times[5] = (t.hold + t.out_start) / 2
    return times


def grab(cap, t: float) -> Image.Image:
    fps = cap.get(cv2.CAP_PROP_FPS) or 30.0
    cap.set(cv2.CAP_PROP_POS_FRAMES, round(t * fps))
    ok, bgr = cap.read()
    if not ok:
        raise RuntimeError(f"could not read frame at {t:.2f}s")
    img = Image.fromarray(cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB))
    return img.resize((FRAME_W, FRAME_H), Image.LANCZOS)


def build_rows() -> list[tuple[str, list[Image.Image | None]]]:
    rows = []
    for spec in ALL_VIDEOS:
        cap = cv2.VideoCapture(str(VIDEO_DIR / f"{spec.id}.mp4"))
        if not cap.isOpened():
            raise RuntimeError(f"cannot open {spec.id}.mp4")
        frames = [None if t is None else grab(cap, t) for t in frame_times(spec)]
        cap.release()
        rows.append((spec.id, frames))
    return rows


def compose(rows) -> Image.Image:
    width = LABEL_W + len(COLUMNS) * (FRAME_W + GAP)
    height = HEADER_H + len(rows) * (FRAME_H + GAP)
    sheet = Image.new("RGB", (width, height), BG)
    draw = ImageDraw.Draw(sheet)
    head_font, label_font = font(18), font(17)
    for c, name in enumerate(COLUMNS):
        x = LABEL_W + c * (FRAME_W + GAP)
        draw.text((x + 4, 6), name, fill=INK, font=head_font)
    for r, (vid, frames) in enumerate(rows):
        y = HEADER_H + r * (FRAME_H + GAP)
        draw.text((8, y + FRAME_H // 2 - 10), vid, fill=INK, font=label_font)
        for c, frame in enumerate(frames):
            if frame is not None:
                sheet.paste(frame, (LABEL_W + c * (FRAME_W + GAP), y))
    return sheet


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    rows = build_rows()
    compose(rows).save(OUT_DIR / "contact_sheet.png")
    parts = [rows[i:i + ROWS_PER_PART] for i in range(0, len(rows), ROWS_PER_PART)]
    for n, part in enumerate(parts, 1):
        compose(part).save(OUT_DIR / f"contact_sheet_{n}.png")
    print(f"wrote {OUT_DIR / 'contact_sheet.png'} and {len(parts)} parts")


if __name__ == "__main__":
    main()
