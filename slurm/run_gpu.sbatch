#!/bin/bash
#SBATCH --job-name=cv_gpu_train
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --gres=gpu:1
#SBATCH --time=04:00:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

set -e

PROJECT_DIR="/project/zz992000-zdevb/zz992005/${USER}/lpr-hackathon"
cd "$PROJECT_DIR"

source ~/.bashrc
conda activate lanta-cv

python src/check_env.py
python src/train_yolo_example.py
