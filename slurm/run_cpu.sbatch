#!/bin/bash
#SBATCH --job-name=cv-cpu-check
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

set -euo pipefail
cd "$SLURM_SUBMIT_DIR"

# ปรับ module ให้ตรงกับระบบจริงของ LANTA
# module load Miniforge3
# source ~/miniforge3/etc/profile.d/conda.sh
conda activate cvhack

echo "Job ID: $SLURM_JOB_ID"
echo "Node: $(hostname)"
echo "Workdir: $(pwd)"
echo "Python: $(which python)"
python --version

python src/check_env.py
