"""Fidelity check: the re-rendered bridge must match the owner's video.

Compares the new figure and room against frames of the owner's
pelvic_bridge_side_view.mp4 at hip elevations 0, 0.5 and 1, masking the
overlay regions (title panel, rep panel, cue bar, alignment guide) that the
new video deliberately removes or redraws.
"""
import sys
from pathlib import Path

import cv2
import numpy as np

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE / "reference"))

REF_VIDEO = HERE.parents[1].parent / "Videos" / "pelvic_bridge_side_view.mp4"
LIMIT = 3.0


def main() -> int:
    import studio
    from exercises import pelvic_bridging  # noqa: E402  (fails until implemented)
    import bridge as ref  # the owner's script, for its timeline

    cap = cv2.VideoCapture(str(REF_VIDEO))
    if not cap.isOpened():
        print("cannot open", REF_VIDEO)
        return 2
    room = studio.make_room()
    # Reference timeline: intro rest, mid-lift, hold plateau.
    targets = {0.0: 0.3, 0.5: 1.45, 1.0: 2.6}
    ok = True
    for e_target, t_ref in targets.items():
        idx = round(t_ref * ref.FPS)
        cap.set(cv2.CAP_PROP_POS_FRAMES, idx)
        good, bgr = cap.read()
        if not good:
            print("cannot read ref frame", idx)
            return 2
        ref_rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB).astype(np.float32)
        e_ref = ref.state(idx / ref.FPS)[0]
        mine = np.asarray(pelvic_bridging.render_elevation(e_ref, room), dtype=np.float32)
        mask = np.ones(mine.shape[:2], dtype=bool)
        mask[26:108, 28:430] = False
        mask[26:108, 1032:1252] = False
        mask[636:, :] = False
        if e_target == 1.0:
            x0, y0, x1, y1 = pelvic_bridging.guide_bbox()
            mask[y0:y1, x0:x1] = False
        diff = float(np.abs(mine - ref_rgb).mean(axis=2)[mask].mean())
        status = "ok" if diff < LIMIT else "FAIL"
        print(f"e={e_target:<3} (ref frame {idx}, e_ref={e_ref:.3f}): mean abs diff {diff:.3f}  {status}")
        ok = ok and diff < LIMIT
    print("PASS" if ok else "FAIL")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
