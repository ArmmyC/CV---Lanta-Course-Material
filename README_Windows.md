# README Windows: ใช้ LANTA สำหรับ Computer Vision Hackathon

คู่มือนี้เหมาะกับ Windows 10/11 โดยแนะนำให้ใช้ **Windows Terminal + PowerShell** หรือ **Git Bash**

> เปลี่ยน `<USERNAME>` เป็น username ของคุณ  
> Host: `transfer.lanta.nstda.or.th`

## 0. สิ่งที่ต้องมีบน Windows

แนะนำติดตั้ง:

- Windows Terminal
- Git for Windows, เพื่อใช้ Git Bash และ command แบบ Linux
- VS Code
- OpenSSH Client, ปกติ Windows 10/11 มีให้แล้ว

ตรวจใน PowerShell:

```powershell
ssh -V
scp -V
git --version
```

ถ้าใช้ Git Bash ให้เปิด Git Bash แล้วตรวจ:

```bash
ssh -V
scp -V
git --version
make --version
```

ถ้า `make` ไม่มี ไม่เป็นไร ใช้ command ตรงแทนได้

---

## 1. SSH เข้า LANTA ครั้งแรก

PowerShell:

```powershell
ssh <USERNAME>@transfer.lanta.nstda.or.th
```

หลังเข้าได้ ให้ลอง:

```bash
hostname
pwd
whoami
```

ออกจาก LANTA:

```bash
exit
```

สิ่งที่ได้จากขั้นนี้:

- รู้ว่า account ใช้งานได้ไหม
- รู้ว่า network เข้า LANTA ได้ไหม
- รู้ว่า shell บน LANTA ใช้งานได้ไหม

---

## 2. สร้าง SSH key เพื่อไม่ต้องพิมพ์ password ทุกครั้ง

สร้าง key ใน PowerShell:

```powershell
ssh-keygen -t ed25519 -C "<USERNAME>@lanta" -f $env:USERPROFILE\.ssh\lanta_ed25519
```

กด Enter ตามขั้นตอน ถ้าใช้จริงควรตั้ง passphrase แต่ถ้า workshop ต้องการเร็ว อาจเว้นว่างได้

ดู public key:

```powershell
Get-Content $env:USERPROFILE\.ssh\lanta_ed25519.pub
```

เพิ่ม public key ไปที่ LANTA:

```powershell
type $env:USERPROFILE\.ssh\lanta_ed25519.pub | ssh <USERNAME>@transfer.lanta.nstda.or.th "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
```

ทดสอบ:

```powershell
ssh -i $env:USERPROFILE\.ssh\lanta_ed25519 <USERNAME>@transfer.lanta.nstda.or.th
```

สิ่งที่ได้จากขั้นนี้:

- เข้า LANTA ได้เร็วขึ้น
- ลดปัญหา password ตอน scp/upload หลายรอบ
- พร้อมใช้ SSH config

---

## 3. สร้าง SSH config

สร้างหรือเปิดไฟล์:

```powershell
notepad $env:USERPROFILE\.ssh\config
```

ใส่เนื้อหานี้:

```sshconfig
Host lanta-transfer
    HostName transfer.lanta.nstda.or.th
    User <USERNAME>
    IdentityFile ~/.ssh/lanta_ed25519
    IdentitiesOnly yes
```

ทดสอบ:

```powershell
ssh lanta-transfer
```

ต่อไปนี้ไม่ต้องพิมพ์ host ยาว ๆ แล้ว

---

## 4. ใช้ Makefile บน Windows

ถ้าใช้ Git Bash และมี `make`:

```bash
make ssh
make upload-code
make job-cpu
make job-gpu
```

ถ้าใช้ PowerShell และไม่มี `make` ให้ใช้ command ตรง เช่น:

```powershell
ssh lanta-transfer
scp .\src\check_env.py lanta-transfer:~/projects/lpr-hackathon/src/
```

ตัวอย่าง config ใน Makefile ที่ควรแก้:

```makefile
REMOTE_HOST=lanta-transfer
REMOTE_PROJECT=~/projects/lpr-hackathon
```

---

## 5. สร้าง project folder บน LANTA

เข้า LANTA:

```powershell
ssh lanta-transfer
```

บน LANTA:

```bash
mkdir -p ~/projects/lpr-hackathon/{data,src,slurm,outputs,logs,models}
cd ~/projects/lpr-hackathon
pwd
ls -la
```

สิ่งที่ได้:

- โครงสร้าง project ชัด
- แยก data/code/output/log ไม่ปนกัน

---

## 6. Permission ที่ควรรู้: chmod

บน LANTA:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod +x src/*.py
```

ความหมายสั้น ๆ:

| Command | ใช้ทำอะไร |
|---|---|
| `chmod 700 ~/.ssh` | ให้เจ้าของอ่าน/เขียน/เข้า folder ได้คนเดียว |
| `chmod 600 authorized_keys` | ให้เจ้าของอ่าน/เขียน key file ได้คนเดียว |
| `chmod +x file.py` | ทำให้ file execute ได้ |

---

## 7. สร้าง environment ด้วย mamba/conda

เช็กว่ามี mamba/conda ไหม:

```bash
mamba --version
conda --version
```

ถ้ามี `environment.yml`:

```bash
mamba env create -f environment.yml
```

ถ้าไม่มี mamba ใช้ conda:

```bash
conda env create -f environment.yml
```

Activate:

```bash
conda activate lanta-cv
```

เช็ก Python:

```bash
which python
python --version
```

---

## 8. ติดตั้ง library ด้วย pip

บน LANTA หลัง activate env:

```bash
pip install -r requirements.txt
```

หรือถ้าติดตั้งเอง:

```bash
pip install ultralytics opencv-python pandas matplotlib tqdm scikit-learn
```

เช็กว่า import ได้ไหม:

```bash
python -c "import cv2, pandas, ultralytics; print('OK')"
```

---

## 9. Upload data ไป LANTA ด้วย scp

PowerShell จากเครื่องเรา:

```powershell
scp -r .\data\ lanta-transfer:~/projects/lpr-hackathon/data/
```

Upload code:

```powershell
scp -r .\src\ lanta-transfer:~/projects/lpr-hackathon/
scp -r .\slurm\ lanta-transfer:~/projects/lpr-hackathon/
scp .\requirements.txt lanta-transfer:~/projects/lpr-hackathon/
scp .\environment.yml lanta-transfer:~/projects/lpr-hackathon/
```

ถ้าใช้ Git Bash ใช้ path แบบนี้ได้:

```bash
scp -r ./data/ lanta-transfer:~/projects/lpr-hackathon/data/
scp -r ./src/ ./slurm/ lanta-transfer:~/projects/lpr-hackathon/
```

---

## 10. Upload ไฟล์ `.py` หรือ `.ipynb`

PowerShell:

```powershell
scp .\notebooks\experiment.ipynb lanta-transfer:~/projects/lpr-hackathon/src/
scp .\src\train.py lanta-transfer:~/projects/lpr-hackathon/src/
```

บน LANTA เช็กไฟล์:

```bash
ls -lh ~/projects/lpr-hackathon/src/
```

หมายเหตุ: บน HPC มักนิยมรัน `.py` ผ่าน Slurm มากกว่า `.ipynb` ถ้ามี notebook ให้ export เป็น Python script ก่อน

---

## 11. Slurm template สำหรับ CPU

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

## 12. Slurm template สำหรับ GPU

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

> ถ้า partition ไม่ใช่ `gpu` ให้เช็กด้วย `sinfo`

---

## 13. ดูสถานะ job, log, cancel job

บน LANTA:

```bash
squeue -u $USER
sinfo
```

ดู log:

```bash
ls -lh logs/
tail -f logs/cv_gpu_train-<JOB_ID>.out
```

ยกเลิก job:

```bash
scancel <JOB_ID>
```

---

## 14. Download output กลับ Windows

PowerShell:

```powershell
scp -r lanta-transfer:~/projects/lpr-hackathon/outputs/ .\outputs\
scp -r lanta-transfer:~/projects/lpr-hackathon/logs/ .\logs\
scp -r lanta-transfer:~/projects/lpr-hackathon/models/ .\models\
```

Git Bash:

```bash
scp -r lanta-transfer:~/projects/lpr-hackathon/outputs/ ./outputs/
scp -r lanta-transfer:~/projects/lpr-hackathon/logs/ ./logs/
scp -r lanta-transfer:~/projects/lpr-hackathon/models/ ./models/
```

---

## 15. Computer Vision workflow บน LANTA

สำหรับ license plate / object detection:

```text
local machine
→ เตรียม dataset
→ upload data ไป LANTA
→ train YOLO ด้วย Slurm GPU
→ save model best.pt ใน models/
→ run inference
→ save annotated images ใน outputs/
→ download outputs กลับมา
```

สิ่งที่ควรให้ทีมดู:

```bash
python -c "import torch; print(torch.cuda.is_available())"
nvidia-smi || true
tegrastats || true
```

บางเครื่อง login node อาจไม่มี GPU ให้เช็ก GPU ใน job log แทน

---

## 16. Troubleshooting Windows

| ปัญหา | วิธีแก้ |
|---|---|
| `ssh` ใช้ไม่ได้ | เปิด Optional Features แล้วติดตั้ง OpenSSH Client หรือใช้ Git Bash |
| `Permission denied (publickey)` | เช็ก path key ใน `~/.ssh/config`, เช็ก `authorized_keys` บน LANTA |
| `scp` path ผิด | PowerShell ใช้ `.olderile`, Git Bash ใช้ `./folder/file` |
| `make` ไม่มี | ใช้ Git Bash/MSYS2 หรือรัน command ตรงแทน |
| upload ช้ามาก | zip data ก่อน หรือใช้ rsync ถ้ามี |
| conda activate ไม่ได้ | ลอง `source ~/.bashrc` แล้ว `conda activate lanta-cv` |
| job pending | เช็ก `squeue`, `sinfo`, partition, quota, time limit |

---

## 17. Cheat Sheet Windows

```powershell
ssh <USERNAME>@transfer.lanta.nstda.or.th
ssh-keygen -t ed25519 -C "<USERNAME>@lanta" -f $env:USERPROFILE\.ssh\lanta_ed25519
notepad $env:USERPROFILE\.ssh\config
ssh lanta-transfer
scp -r .\data\ lanta-transfer:~/projects/lpr-hackathon/data/
scp -r lanta-transfer:~/projects/lpr-hackathon/outputs/ .\outputs\
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
