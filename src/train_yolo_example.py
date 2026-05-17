"""
Minimal YOLO training/inference example.

Before running:
1. Put your dataset in data/
2. Create a YOLO data.yaml, for example:
   data/license_plate.yaml
3. Update DATA_YAML below.

This script is intentionally simple for a hackathon workshop.
"""

from pathlib import Path
from ultralytics import YOLO

PROJECT_DIR = Path("/project/992000-zdevb/zz992005").expanduser()
CURRENT_DIR = Path.cwd()

DATA_YAML = CURRENT_DIR / "data" / "license_plate.yaml"
MODEL_NAME = "yolo11n.pt"  # use yolo11n.pt first, then try yolo11s.pt if time/GPU allows

def main():
    print("Working directory:", CURRENT_DIR)
    print("Data yaml:", DATA_YAML)

    if not DATA_YAML.exists():
        print(f"WARNING: {DATA_YAML} not found.")
        print("This script will run environment-level checks only.")
        print("Create data/license_plate.yaml before real training.")
        return

    model = YOLO(MODEL_NAME)

    results = model.train(
        data=str(DATA_YAML),
        imgsz=640,
        epochs=10,
        batch=16,
        project="outputs",
        name="yolo_plate_baseline",
        exist_ok=True,
    )

    model.val()

    # Save the final model path note
    print("Training finished.")
    print("Check outputs/yolo_plate_baseline/weights/best.pt")

if __name__ == "__main__":
    main()
