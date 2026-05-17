from pathlib import Path
from ultralytics import YOLO

DATA_YAML = Path("data/data.yaml")

if not DATA_YAML.exists():
    raise FileNotFoundError(
        "ไม่พบ data/data.yaml กรุณาอัปโหลด dataset และแก้ path ให้ถูกก่อนรัน training"
    )

model = YOLO("yolo11n.pt")
model.train(
    data=str(DATA_YAML),
    imgsz=640,
    epochs=5,
    batch=16,
    project="models",
    name="plate_yolo11n_debug",
)
