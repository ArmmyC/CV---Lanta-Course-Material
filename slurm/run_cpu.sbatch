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

cd ~/projects/lpr-hackathon
source ~/.bashrc
conda activate lanta-cv

python src/check_env.py
