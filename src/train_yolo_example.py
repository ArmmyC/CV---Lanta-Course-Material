from pathlib import Path

# Template only. Replace data.yaml with your dataset config.
# Example command inside Slurm job:
#   python src/train_yolo_example.py

from ultralytics import YOLO

PROJECT_DIR = Path.home() / "projects" / "lpr-hackathon"
DATA_YAML = PROJECT_DIR / "data" / "data.yaml"
OUTPUT_DIR = PROJECT_DIR / "outputs"
MODEL_DIR = PROJECT_DIR / "models"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
MODEL_DIR.mkdir(parents=True, exist_ok=True)

print("Project:", PROJECT_DIR)
print("Data yaml:", DATA_YAML)

if not DATA_YAML.exists():
    print("data.yaml not found. This is expected for the template.")
    print("Put your YOLO dataset config at:", DATA_YAML)
    raise SystemExit(0)

model = YOLO("yolo11n.pt")
results = model.train(
    data=str(DATA_YAML),
    imgsz=640,
    epochs=10,
    batch=16,
    project=str(OUTPUT_DIR),
    name="yolo_lpr_baseline",
)
print(results)
