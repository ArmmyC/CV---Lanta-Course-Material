#!/bin/bash
#SBATCH --job-name=cv_cpu_test
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=01:00:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

set -e

PROJECT_DIR="/project/992000-zdevb/zz992005/${USER}/lpr-hackathon"
cd "$PROJECT_DIR"

source ~/.bashrc
conda activate lanta-cv

python src/check_env.py
