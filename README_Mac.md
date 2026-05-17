# README macOS: ใช้ LANTA สำหรับ Computer Vision Hackathon

คู่มือนี้เหมาะกับ macOS โดยใช้ Terminal, iTerm2 หรือ VS Code terminal

> เปลี่ยน `<USERNAME>` เป็น username ของคุณ  
> Host: `transfer.lanta.nstda.or.th`

## 0. สิ่งที่ต้องมีบน macOS

macOS มี `ssh` และ `scp` มาให้แล้วโดยปกติ

ตรวจ:

```bash
ssh -V
scp -V
git --version
make --version
```

ถ้ายังไม่มี Git หรือ make อาจต้องติดตั้ง Xcode Command Line Tools:

```bash
xcode-select --install
```

แนะนำเพิ่มเติม:

```bash
brew --version
```

ถ้าไม่มี Homebrew แต่ไม่จำเป็นสำหรับ workshop ก็ข้ามได้

---

## 1. SSH เข้า LANTA ครั้งแรก

```bash
ssh <USERNAME>@transfer.lanta.nstda.or.th
```

หลังเข้าได้:

```bash
hostname
pwd
whoami
```

ออกจาก LANTA:

```bash
exit
```

---

## 2. สร้าง SSH key

บนเครื่อง Mac:

```bash
ssh-keygen -t ed25519 -C "<USERNAME>@lanta" -f ~/.ssh/lanta_ed25519
```

ดู public key:

```bash
cat ~/.ssh/lanta_ed25519.pub
```

เพิ่ม public key ไป LANTA:

```bash
ssh-copy-id -i ~/.ssh/lanta_ed25519.pub <USERNAME>@transfer.lanta.nstda.or.th
```

ถ้า macOS ไม่มี `ssh-copy-id`:

```bash
cat ~/.ssh/lanta_ed25519.pub | ssh <USERNAME>@transfer.lanta.nstda.or.th "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
```

ทดสอบ:

```bash
ssh -i ~/.ssh/lanta_ed25519 <USERNAME>@transfer.lanta.nstda.or.th
```

---

## 3. สร้าง SSH config

เปิดไฟล์:

```bash
nano ~/.ssh/config
```

ใส่:

```sshconfig
Host lanta-transfer
    HostName transfer.lanta.nstda.or.th
    User <USERNAME>
    IdentityFile ~/.ssh/lanta_ed25519
    IdentitiesOnly yes
```

ตั้ง permission:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/lanta_ed25519
```

ทดสอบ:

```bash
ssh lanta-transfer
```

---

## 4. ใช้ Makefile

แก้ค่าด้านบนของ `Makefile`:

```makefile
REMOTE_HOST=lanta-transfer
REMOTE_PROJECT=~/projects/lpr-hackathon
```

ใช้ command สั้น:

```bash
make ssh
make upload-code
make upload-data
make job-cpu
make job-gpu
make download-output
```

---

## 5. สร้าง project folder บน LANTA

```bash
ssh lanta-transfer
```

บน LANTA:

```bash
mkdir -p ~/projects/lpr-hackathon/{data,src,slurm,outputs,logs,models}
cd ~/projects/lpr-hackathon
pwd
ls -la
```

---

## 6. Permission ที่ควรรู้

บน LANTA:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod +x src/*.py
```

ดู permission:

```bash
ls -la
ls -la ~/.ssh
```

---

## 7. สร้าง environment ด้วย mamba/conda

บน LANTA:

```bash
mamba --version || true
conda --version || true
```

สร้าง env:

```bash
mamba env create -f environment.yml
```

ถ้าไม่มี mamba:

```bash
conda env create -f environment.yml
```

Activate:

```bash
conda activate lanta-cv
```

เช็ก:

```bash
which python
python --version
```

---

## 8. ติดตั้ง library ด้วย pip

```bash
pip install -r requirements.txt
```

หรือ:

```bash
pip install ultralytics opencv-python pandas matplotlib tqdm scikit-learn
```

ทดสอบ:

```bash
python -c "import cv2, pandas, ultralytics; print('OK')"
```

---

## 9. Upload data/code ไป LANTA

จากเครื่อง Mac:

```bash
scp -r ./data/ lanta-transfer:~/projects/lpr-hackathon/data/
scp -r ./src/ ./slurm/ lanta-transfer:~/projects/lpr-hackathon/
scp ./requirements.txt ./environment.yml lanta-transfer:~/projects/lpr-hackathon/
```

ถ้าไฟล์ใหญ่ ใช้ rsync:

```bash
rsync -avP ./data/ lanta-transfer:~/projects/lpr-hackathon/data/
```

Upload notebook หรือ script:

```bash
scp ./notebooks/experiment.ipynb lanta-transfer:~/projects/lpr-hackathon/src/
scp ./src/train.py lanta-transfer:~/projects/lpr-hackathon/src/
```

---

## 10. Slurm template สำหรับ CPU

ไฟล์: `slurm/run_cpu.sbatch`

```bash
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
```

ส่ง job:

```bash
sbatch slurm/run_cpu.sbatch
```

---

## 11. Slurm template สำหรับ GPU

ไฟล์: `slurm/run_gpu.sbatch`

```bash
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

cd ~/projects/lpr-hackathon
source ~/.bashrc
conda activate lanta-cv

python src/train_yolo_example.py
```

ส่ง job:

```bash
sbatch slurm/run_gpu.sbatch
```

ถ้า partition ไม่ตรง:

```bash
sinfo
```

แล้วแก้ `#SBATCH --partition=...`

---

## 12. ดู job, log, cancel

```bash
squeue -u $USER
sinfo
```

ดู log:

```bash
ls -lh logs/
tail -f logs/cv_gpu_train-<JOB_ID>.out
```

ยกเลิก:

```bash
scancel <JOB_ID>
```

---

## 13. Download output กลับ Mac

```bash
scp -r lanta-transfer:~/projects/lpr-hackathon/outputs/ ./outputs/
scp -r lanta-transfer:~/projects/lpr-hackathon/logs/ ./logs/
scp -r lanta-transfer:~/projects/lpr-hackathon/models/ ./models/
```

หรือ:

```bash
rsync -avP lanta-transfer:~/projects/lpr-hackathon/outputs/ ./outputs/
```

---

## 14. Computer Vision workflow บน LANTA

```text
เตรียม dataset local
→ upload ไป LANTA
→ activate env
→ submit GPU job
→ train YOLO / run inference
→ save outputs
→ download outputs กลับมา
```

คำสั่งตรวจ GPU ใน job script:

```bash
python -c "import torch; print('CUDA:', torch.cuda.is_available()); print(torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'No GPU')"
nvidia-smi || true
```

---

## 15. Troubleshooting macOS

| ปัญหา | วิธีแก้ |
|---|---|
| `make` หรือ `git` ไม่มี | รัน `xcode-select --install` |
| `ssh-copy-id` ไม่มี | ใช้วิธี `cat key | ssh ...` ตามด้านบน |
| `Permission denied` | เช็ก key path และ permission ใน `~/.ssh` |
| upload หลุด | ใช้ `rsync -avP` |
| conda activate ไม่ได้ | `source ~/.bashrc` หรือหา conda init path |
| job pending | เช็ก `squeue`, `sinfo`, partition, quota |
| CUDA ไม่เจอ | เช็กว่า job ใช้ GPU partition จริง |

---

## 16. Cheat Sheet macOS

```bash
ssh <USERNAME>@transfer.lanta.nstda.or.th
ssh-keygen -t ed25519 -C "<USERNAME>@lanta" -f ~/.ssh/lanta_ed25519
ssh-copy-id -i ~/.ssh/lanta_ed25519.pub <USERNAME>@transfer.lanta.nstda.or.th
nano ~/.ssh/config
ssh lanta-transfer
scp -r ./data/ lanta-transfer:~/projects/lpr-hackathon/data/
scp -r lanta-transfer:~/projects/lpr-hackathon/outputs/ ./outputs/
```

บน LANTA:

```bash
mkdir -p ~/projects/lpr-hackathon/{data,src,slurm,outputs,logs,models}
cd ~/projects/lpr-hackathon
mamba env create -f environment.yml
conda activate lanta-cv
pip install -r requirements.txt
sbatch slurm/run_cpu.sbatch
sbatch slurm/run_gpu.sbatch
squeue -u $USER
tail -f logs/<LOG_FILE>.out
```
