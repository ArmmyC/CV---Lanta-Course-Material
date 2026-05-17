#!/bin/bash
#SBATCH --job-name=cv-gpu-train
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --gres=gpu:1
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

set -euo pipefail
cd "$SLURM_SUBMIT_DIR"

# ปรับ module ให้ตรงกับระบบจริงของ LANTA
# module load Miniforge3
# module load CUDA
# source ~/miniforge3/etc/profile.d/conda.sh
conda activate cvhack

echo "Job ID: $SLURM_JOB_ID"
echo "Node: $(hostname)"
echo "Workdir: $(pwd)"
echo "Python: $(which python)"
python --version

nvidia-smi || true

python - <<'PY'
import torch
print("torch:", torch.__version__)
print("cuda available:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("gpu:", torch.cuda.get_device_name(0))
PY

python src/train_yolo_example.py
