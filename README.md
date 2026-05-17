# Workshop: ใช้ LANTA สำหรับ Computer Vision Hackathon by Armmy Pangpuriye

README นี้ออกแบบให้ใช้เป็นเอกสารสอนทีมแบบ follow-along ระหว่างที่คนสอนแชร์หน้าจอ เหมาะกับงาน Computer Vision ที่ต้องอัปโหลด data/code ขึ้น LANTA, สร้าง environment, ส่งงานผ่าน Slurm, และดึงผลลัพธ์กลับมา

> แก้ค่าที่เขียนว่า `<USERNAME>` ให้เป็น username ของแต่ละคนก่อนรัน command  
> Host ที่ใช้ในตัวอย่าง: `transfer.lanta.nstda.or.th`  
> ชื่อ partition/account ของ LANTA อาจไม่เหมือน template ด้านล่าง ให้เช็กด้วย `sinfo`, `sacctmgr` หรือเช็คอีเมลล์

---

## สารบัญ

1. ภาพรวมที่ต้องเข้าใจก่อนเริ่ม
2. แผนการสอนแบบ 90 นาที
3. สิ่งที่ต้องเตรียมก่อน workshop
4. SSH เข้า LANTA ครั้งแรก
5. สร้าง SSH key เพื่อไม่ต้องพิมพ์ password ทุกครั้ง
6. ตั้งค่า SSH config ให้สั้นลง
7. ตั้ง Makefile เพื่อใช้ command สั้น ๆ
8. สร้าง folder project บน LANTA
9. Permission ที่ควรรู้: `chmod`
10. สร้าง Python environment ด้วย mamba/conda
11. ติดตั้ง library ด้วย pip
12. อัปโหลด data ไป LANTA ด้วย scp
13. อัปโหลดไฟล์ `.py` หรือ `.ipynb`
14. เขียน Slurm script สำหรับ CPU
15. เขียน Slurm script สำหรับ GPU
16. ส่ง job, ดูสถานะ, ดู log, ยกเลิก job
17. ดาวน์โหลด output กลับมาที่เครื่องเรา
18. Workflow สำหรับ Computer Vision
19. Troubleshooting
20. Cheat Sheet

---

## 1. ภาพรวมที่ต้องเข้าใจก่อนเริ่ม

LANTA เป็นเครื่องคำนวณแบบ HPC ไม่ใช่เครื่อง local ธรรมดา วิธีคิดหลักคือ

```text
เครื่องเรา
→ SSH เข้า transfer/login node
→ เตรียม folder, environment, data, code
→ ส่งงานไป compute node ด้วย Slurm
→ รอ job รันเสร็จ
→ ดู log/result
→ scp output กลับมา
```

สิ่งสำคัญ:

- อย่ารันงานหนักบน transfer/login node โดยตรง
- งาน train model ควรส่งผ่าน Slurm
- data, model, output ควรจัด folder ให้ชัดตั้งแต่แรก
- ใช้ environment แยกต่อ project เพื่อกัน dependency พัง
- เก็บ private key ไว้กับตัวเอง ห้ามส่งให้ใคร

---

## 2. แผนการสอนแบบ 90 นาที

|           เวลา | หัวข้อ                            | เป้าหมาย                          |
| -------------: | --------------------------------- | --------------------------------- |
|  0 ถึง 10 นาที | Concept: local vs LANTA vs Slurm  | ทุกคนเข้าใจว่าทำไมต้อง submit job |
| 10 ถึง 25 นาที | SSH เข้าเครื่อง + SSH key         | ทุกคนเข้า LANTA ได้               |
| 25 ถึง 35 นาที | SSH config + Makefile             | ใช้ command สั้น เช่น `make ssh`  |
| 35 ถึง 45 นาที | สร้าง project folder + permission | โครงสร้าง project พร้อมใช้งาน     |
| 45 ถึง 60 นาที | mamba/conda + pip install         | environment พร้อมสำหรับ CV        |
| 60 ถึง 70 นาที | upload data/code ด้วย scp         | data/code อยู่บน LANTA            |
| 70 ถึง 85 นาที | Slurm CPU/GPU template            | submit job ได้จริง                |
| 85 ถึง 90 นาที | download output + recap           | ทุกคนเห็น workflow เต็มรอบ        |

วิธีสอนที่แนะนำ:

1. ให้ทุกคน clone หรือเปิด README นี้
2. คนสอนแชร์จอและรันทีละ section
3. หลังจบแต่ละ section ให้ทุกคนพิมพ์ command ตรวจสอบ เช่น `pwd`, `ls`, `squeue -u $USER`
4. ห้ามข้ามขั้น SSH key/config เพราะจะช่วยลดปัญหาตอน hackathon มาก
5. ใช้ project เล็ก ๆ ก่อน เช่น `check_env.py` แล้วค่อย train model จริง

---

## 3. สิ่งที่ต้องเตรียมก่อน workshop

### ทุกระบบต้องมี

- LANTA username/password
- Terminal
- `ssh`
- `scp`
- editor เช่น VS Code
- Git, แนะนำแต่ไม่บังคับ

### Windows

ใช้ได้ 2 ทาง

**ทางเลือก A: PowerShell / Windows Terminal**

ตรวจว่า ssh ใช้ได้ไหม:

```powershell
ssh -V
```

**ทางเลือก B: Git Bash**

เหมาะกว่าเมื่อจะใช้ command แนว Linux/macOS เช่น `make`, `mkdir -p`, `cat`

ตรวจว่าใช้ได้ไหม:

```bash
ssh -V
make --version
```

ถ้าไม่มี `make` บน Windows ให้ใช้ PowerShell command แทน หรือใช้ Git Bash/MSYS2

### macOS / Linux

ตรวจว่า ssh/scp ใช้ได้ไหม:

```bash
ssh -V
```

ตรวจว่า make ใช้ได้ไหม:

```bash
make --version
```

---

## 4. SSH เข้า LANTA ครั้งแรก

### Windows PowerShell

```powershell
ssh <USERNAME>@transfer.lanta.nstda.or.th
```

### macOS / Linux / Git Bash

```bash
ssh <USERNAME>@transfer.lanta.nstda.or.th
```

ถ้าเข้าได้ จะอยู่ใน shell ของ LANTA ให้ลองเช็ก:

```bash
pwd
whoami
```

ออกจาก LANTA:

```bash
exit
```

---

## 5. สร้าง SSH key เพื่อไม่ต้องพิมพ์ password ทุกครั้ง

SSH key มี 2 ไฟล์:

```text
private key: เก็บไว้ที่เครื่องเรา ห้ามแชร์
public key: เอาไปใส่บน LANTA ได้
```

### 5.1 สร้าง key บน Windows PowerShell

```powershell
ssh-keygen -t ed25519 -C "lanta" -f $env:USERPROFILE\.ssh\lanta_ed25519
```

เช่น

```powershell
ssh-keygen -t ed25519 -C "lanta" -f $env:USERPROFILE\.ssh\lanta_ed25519
```

กด Enter ตามขั้นตอน ถ้าต้องการเร็วสำหรับ workshop อาจไม่ใส่ passphrase ได้ แต่ถ้าใช้งานจริงควรใส่ passphrase

ดู public key:

```powershell
Get-Content $env:USERPROFILE\.ssh\lanta_ed25519.pub
```

### 5.2 สร้าง key บน macOS / Linux / Git Bash

```bash
ssh-keygen -t ed25519 -C "lanta" -f ~/.ssh/lanta_ed25519
```

ดู public key:

```bash
cat ~/.ssh/lanta_ed25519.pub
```

---

## 6. เอา public key ไปใส่บน LANTA

### วิธีที่ 1: macOS / Linux ถ้ามี `ssh-copy-id`

```bash
ssh-copy-id -i ~/.ssh/lanta_ed25519.pub <USERNAME>@transfer.lanta.nstda.or.th
```

### วิธีที่ 2: Windows PowerShell

```powershell
type $env:USERPROFILE\.ssh\lanta_ed25519.pub | ssh <USERNAME>@transfer.lanta.nstda.or.th "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
```

### วิธีที่ 3: macOS / Linux / Git Bash แบบไม่ใช้ `ssh-copy-id`

```bash
cat ~/.ssh/lanta_ed25519.pub | ssh <USERNAME>@transfer.lanta.nstda.or.th "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
```

ทดสอบเข้าโดยใช้ key:

### Windows PowerShell

```powershell
ssh -i $env:USERPROFILE\.ssh\lanta_ed25519 <USERNAME>@transfer.lanta.nstda.or.th
```

### macOS / Linux / Git Bash

```bash
ssh -i ~/.ssh/lanta_ed25519 <USERNAME>@transfer.lanta.nstda.or.th
```

ถ้าไม่ต้องพิมพ์ password แปลว่าผ่าน

---

## 7. ตั้งค่า SSH config ให้สั้นลง

เป้าหมายคือจากเดิม:

```bash
ssh -i ~/.ssh/lanta_ed25519 <USERNAME>@transfer.lanta.nstda.or.th
```

ให้เหลือ:

```bash
ssh lanta-transfer
```

### Windows PowerShell

เปิดไฟล์ config:

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
    ServerAliveInterval 60
    ServerAliveCountMax 5
```

ถ้า Windows หา `~` ไม่เจอ ให้เปลี่ยนเป็น path เต็ม เช่น:

```sshconfig
IdentityFile C:/Users/YOUR_WINDOWS_USERNAME/.ssh/lanta_ed25519
```

### macOS / Linux / Git Bash

```bash
mkdir -p ~/.ssh
nano ~/.ssh/config
```

ใส่เนื้อหานี้:

```sshconfig
Host lanta-transfer
    HostName transfer.lanta.nstda.or.th
    User <USERNAME>
    IdentityFile ~/.ssh/lanta_ed25519
    IdentitiesOnly yes
    ServerAliveInterval 60
    ServerAliveCountMax 5
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

## 8. ตั้ง Makefile เพื่อใช้ command สั้น ๆ

Makefile เหมาะสำหรับทีม เพราะทุกคนใช้ command เหมือนกัน เช่น

```bash
make ssh
make mkdir
make upload-code
make submit-gpu
make download
```

สร้างไฟล์ชื่อ `Makefile` ใน project local:

```makefile
LANTA=lanta-transfer
PROJECT=~/cv-workshop
LOCAL_DATA=./data
REMOTE_DATA=$(PROJECT)/data

ssh:
	ssh $(LANTA)

mkdir:
	ssh $(LANTA) "mkdir -p $(PROJECT)/{data,src,notebooks,slurm,logs,outputs,models}"

upload-data:
	scp -r $(LOCAL_DATA) $(LANTA):$(REMOTE_DATA)

upload-code:
	scp -r src notebooks slurm requirements.txt environment.yml $(LANTA):$(PROJECT)/

submit-cpu:
	ssh $(LANTA) "cd $(PROJECT) && sbatch slurm/run_cpu.sbatch"

submit-gpu:
	ssh $(LANTA) "cd $(PROJECT) && sbatch slurm/run_gpu.sbatch"

status:
	ssh $(LANTA) "squeue -u \$$USER"

logs:
	ssh $(LANTA) "cd $(PROJECT) && ls -lh logs && tail -n 80 logs/*.out 2>/dev/null || true"

download:
	mkdir -p outputs_lanta
	scp -r $(LANTA):$(PROJECT)/outputs ./outputs_lanta
```

บน Windows ถ้าไม่มี `make` ให้ใช้ command ตรงแทน เช่น:

```powershell
ssh lanta-transfer "mkdir -p ~/cv-workshop/{data,src,notebooks,slurm,logs,outputs,models}"
scp -r .\src lanta-transfer:~/cv-workshop/
ssh lanta-transfer "cd ~/cv-workshop && sbatch slurm/run_gpu.sbatch"
```

---

## 9. สร้าง folder project บน LANTA

เข้า LANTA:

```bash
ssh lanta-transfer
```

สร้าง folder:

```bash
mkdir -p ~/cv-workshop/{data,src,notebooks,slurm,logs,outputs,models}
cd ~/cv-workshop
pwd
ls -lah
```

โครงสร้างที่แนะนำ:

```text
cv-workshop/
├── data/        # dataset
├── src/         # python scripts
├── notebooks/   # ipynb files
├── slurm/       # sbatch files
├── logs/        # Slurm stdout/stderr
├── outputs/     # prediction/result
└── models/      # trained weights
```

---

## 10. Permission ที่ควรรู้: chmod

### คำสั่งพื้นฐาน

ดู permission:

```bash
ls -lah
```

ตั้งค่า `.ssh` ให้ปลอดภัย:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

ให้เราอ่าน/เขียน/เข้า folder project ได้ แต่คนอื่นเข้าไม่ได้:

```bash
chmod -R u+rwX,go-rwx ~/cv-workshop
```

ทำให้ script รันได้:

```bash
chmod +x src/train.py
```

ไม่แนะนำ:

```bash
chmod -R 777 ~/cv-workshop
```

เพราะเปิดสิทธิ์กว้างเกินไป

---

## 11. สร้าง environment ด้วย mamba/conda

บน LANTA ให้เช็กก่อนว่ามีอะไรใช้ได้:

```bash
which mamba || true
which conda || true
module avail 2>&1 | head
module avail 2>&1 | grep -i mamba || true
module avail 2>&1 | grep -i conda || true
module avail 2>&1 | grep -i miniconda || true
module avail 2>&1 | grep -i python || true
```

ถ้าระบบใช้ module ให้ลองดูชื่อ module จริงก่อน:

```bash
module avail
```

ตัวอย่าง ถ้ามี Miniforge/Mambaforge:

```bash
module load Miniforge3
```

หรือถ้า conda อยู่ใน home แล้ว:

```bash
source ~/miniforge3/etc/profile.d/conda.sh
```

สร้าง environment:

```bash
mamba create -n cvhack python=3.10 -y
conda activate cvhack
```

ถ้าไม่มี `mamba` แต่มี `conda`:

```bash
conda create -n cvhack python=3.10 -y
conda activate cvhack
```

ตรวจ environment:

```bash
which python
python --version
which pip
```

---

## 12. ติดตั้ง library ด้วย pip

สร้าง `requirements.txt`:

```txt
ultralytics
opencv-python-headless
pandas
numpy
matplotlib
scikit-learn
pillow
tqdm
pyyaml
jupyter
nbconvert
```

ติดตั้ง:

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

ตรวจ PyTorch และ GPU:

```bash
python - <<'PY'
import torch
print("torch:", torch.__version__)
print("cuda available:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("gpu:", torch.cuda.get_device_name(0))
PY
```

ถ้า `torch.cuda.is_available()` เป็น `False` บน login/transfer node อาจไม่ใช่ปัญหา เพราะ GPU จะอยู่บน compute node ตอนส่ง Slurm job

---

## 13. อัปโหลด data ไป LANTA ด้วย scp

### macOS / Linux / Git Bash

อัปโหลด folder data:

```bash
scp -r ./data lanta-transfer:~/cv-workshop/data
```

อัปโหลดไฟล์ zip:

```bash
scp dataset.zip lanta-transfer:~/cv-workshop/data/
```

แตกไฟล์บน LANTA:

```bash
ssh lanta-transfer
cd ~/cv-workshop/data
unzip dataset.zip
```

### Windows PowerShell

อัปโหลด folder data:

```powershell
scp -r .\data lanta-transfer:~/cv-workshop/data
```

อัปโหลดไฟล์ zip:

```powershell
scp .\dataset.zip lanta-transfer:~/cv-workshop/data/
```

แตกไฟล์บน LANTA:

```powershell
ssh lanta-transfer "cd ~/cv-workshop/data && unzip dataset.zip"
```

ถ้า dataset ใหญ่มาก แนะนำใช้ `rsync` บน macOS/Linux/Git Bash เพราะ resume ได้ดีกว่า:

```bash
rsync -avP ./data/ lanta-transfer:~/cv-workshop/data/
```

---

## 14. อัปโหลดไฟล์ `.py` หรือ `.ipynb` ไป LANTA

### อัปโหลดไฟล์ Python

macOS / Linux / Git Bash:

```bash
scp src/train.py lanta-transfer:~/cv-workshop/src/
```

Windows PowerShell:

```powershell
scp .\src\train.py lanta-transfer:~/cv-workshop/src/
```

### อัปโหลดทั้ง folder src

macOS / Linux / Git Bash:

```bash
scp -r ./src lanta-transfer:~/cv-workshop/
```

Windows PowerShell:

```powershell
scp -r .\src lanta-transfer:~/cv-workshop/
```

### อัปโหลด notebook

macOS / Linux / Git Bash:

```bash
scp notebooks/train.ipynb lanta-transfer:~/cv-workshop/notebooks/
```

Windows PowerShell:

```powershell
scp .\notebooks\train.ipynb lanta-transfer:~/cv-workshop/notebooks/
```

รัน notebook แบบ batch บน LANTA:

```bash
jupyter nbconvert --to notebook --execute notebooks/train.ipynb --output notebooks/train_executed.ipynb
```

สำหรับงานจริง แนะนำแปลง notebook เป็น `.py` เพื่อรันผ่าน Slurm ง่ายกว่า:

```bash
jupyter nbconvert --to script notebooks/train.ipynb
```

---

## 15. Slurm script สำหรับ CPU

สร้างไฟล์ `slurm/run_cpu.sbatch`:

```bash
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

# ถ้าระบบใช้ module ให้ปรับชื่อ module ให้ตรงกับ LANTA
# module load Miniforge3

# ถ้า conda ไม่ activate ให้ source conda ก่อน
# source ~/miniforge3/etc/profile.d/conda.sh
conda activate cvhack

echo "Job ID: $SLURM_JOB_ID"
echo "Node: $(hostname)"
echo "Workdir: $(pwd)"
echo "Python: $(which python)"
python --version

python src/check_env.py
```

ส่งงาน:

```bash
cd ~/cv-workshop
sbatch slurm/run_cpu.sbatch
```

---

## 16. Slurm script สำหรับ GPU

สร้างไฟล์ `slurm/run_gpu.sbatch`:

```bash
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

# ถ้าระบบใช้ module ให้ปรับชื่อ module ให้ตรงกับ LANTA
# module load Miniforge3
# module load CUDA

# ถ้า conda ไม่ activate ให้ source conda ก่อน
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
```

บาง cluster ใช้รูปแบบนี้แทน `--gres=gpu:1`:

```bash
#SBATCH --gpus=1
```

ให้ใช้แบบที่ LANTA รองรับจริง โดยเช็กจากเอกสารระบบหรือถาม TA

ส่งงาน:

```bash
cd ~/cv-workshop
sbatch slurm/run_gpu.sbatch
```

---

## 17. ส่ง job, ดูสถานะ, ดู log, ยกเลิก job

ส่ง job:

```bash
sbatch slurm/run_gpu.sbatch
```

ดู job ของเรา:

```bash
squeue -u $USER
```

ดู queue ทั้งหมดแบบสั้น:

```bash
squeue
```

ดู partition/node:

```bash
sinfo
```

ดู log ล่าสุด:

```bash
ls -lh logs
cat logs/*.out
cat logs/*.err
```

ดู log แบบ live:

```bash
tail -f logs/*.out
```

ยกเลิก job:

```bash
scancel <JOB_ID>
```

ดูประวัติ job ถ้าระบบเปิด `sacct`:

```bash
sacct -j <JOB_ID>
```

---

## 18. ดาวน์โหลด output กลับมาที่เครื่องเรา

### macOS / Linux / Git Bash

```bash
scp -r lanta-transfer:~/cv-workshop/outputs ./outputs_lanta
```

ดาวน์โหลด model:

```bash
scp -r lanta-transfer:~/cv-workshop/models ./models_lanta
```

ดาวน์โหลด log:

```bash
scp -r lanta-transfer:~/cv-workshop/logs ./logs_lanta
```

### Windows PowerShell

```powershell
scp -r lanta-transfer:~/cv-workshop/outputs .\outputs_lanta
scp -r lanta-transfer:~/cv-workshop/models .\models_lanta
scp -r lanta-transfer:~/cv-workshop/logs .\logs_lanta
```

---

## 19. Workflow สำหรับ Computer Vision บน LANTA

### Minimal workflow สำหรับ hackathon

```text
1. local: เตรียม code และ data.yaml
2. local → LANTA: scp data/code
3. LANTA: สร้าง conda env
4. LANTA: pip install library
5. LANTA: sbatch GPU training
6. LANTA: ดู log และ metrics
7. LANTA: save model ใน models/
8. LANTA → local: scp outputs/models/logs
9. local: เตรียม presentation/demo
```

### ตัวอย่าง data structure ของ YOLO

```text
data/
├── images/
│   ├── train/
│   └── val/
├── labels/
│   ├── train/
│   └── val/
└── data.yaml
```

ตัวอย่าง `data.yaml`:

```yaml
path: data
train: images/train
val: images/val

names:
  0: license_plate
```

### ตัวอย่าง command train YOLO

```bash
yolo detect train model=yolo11n.pt data=data/data.yaml imgsz=640 epochs=30 batch=16 project=models name=plate_yolo11n
```

หรือใน Python:

```python
from ultralytics import YOLO

model = YOLO("yolo11n.pt")
model.train(
    data="data/data.yaml",
    imgsz=640,
    epochs=30,
    batch=16,
    project="models",
    name="plate_yolo11n"
)
```

หลัง train เสร็จ model มักอยู่ที่:

```text
models/plate_yolo11n/weights/best.pt
```

Predict:

```bash
yolo detect predict model=models/plate_yolo11n/weights/best.pt source=data/images/val save=True project=outputs name=predictions
```

---

## 20. Troubleshooting

### SSH เข้าไม่ได้

เช็ก username และ host:

```bash
ssh -v <USERNAME>@transfer.lanta.nstda.or.th
```

ถ้าใช้ config:

```bash
ssh -v lanta-transfer
```

### Permission denied publickey

บน local:

```bash
ls -lah ~/.ssh
```

บน LANTA:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### conda activate ไม่ได้

ลอง source conda ก่อน:

```bash
source ~/miniforge3/etc/profile.d/conda.sh
conda activate cvhack
```

หรือใช้ module:

```bash
module avail 2>&1 | grep -i conda
module avail 2>&1 | grep -i mamba
```

### pip install ช้ามาก

ใช้ cache หรือ install เฉพาะ package ที่จำเป็นก่อน:

```bash
pip install ultralytics opencv-python-headless pandas numpy tqdm
```

### GPU ใช้ไม่ได้

อย่าเช็กแค่บน transfer node ให้เช็กใน Slurm GPU job:

```bash
nvidia-smi
python -c "import torch; print(torch.cuda.is_available())"
```

### Job pending นาน

ดูเหตุผล:

```bash
squeue -u $USER
scontrol show job <JOB_ID>
```

สาเหตุทั่วไป:

- ขอ GPU มากเกินไป
- ขอ memory/time มากเกินไป
- partition ผิด
- quota หรือ account ยังไม่ถูกต้อง
- queue เต็ม

### Module name ไม่ตรง

อย่าเดา ให้เช็ก:

```bash
module avail
module spider python
module spider cuda
module spider conda
```

---

## 21. Cheat Sheet

### SSH

```bash
ssh <USERNAME>@transfer.lanta.nstda.or.th
ssh lanta-transfer
```

### Copy file

```bash
scp local.txt lanta-transfer:~/cv-workshop/
scp -r ./data lanta-transfer:~/cv-workshop/data
scp -r lanta-transfer:~/cv-workshop/outputs ./outputs_lanta
```

### Folder

```bash
mkdir -p ~/cv-workshop/{data,src,notebooks,slurm,logs,outputs,models}
ls -lah
pwd
```

### Permission

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod -R u+rwX,go-rwx ~/cv-workshop
```

### Conda/mamba

```bash
mamba create -n cvhack python=3.10 -y
conda activate cvhack
pip install -r requirements.txt
```

### Slurm

```bash
sbatch slurm/run_gpu.sbatch
squeue -u $USER
sinfo
tail -f logs/*.out
scancel <JOB_ID>
```

### CV

```bash
yolo detect train model=yolo11n.pt data=data/data.yaml imgsz=640 epochs=30 batch=16 project=models name=plate_yolo11n
yolo detect predict model=models/plate_yolo11n/weights/best.pt source=data/images/val save=True project=outputs name=predictions
```

---

## 22. สิ่งที่ควรให้ทีมจำให้ได้

```text
อย่า train บน transfer node
ใช้ SSH config ให้เรียกง่าย
จัด folder ตั้งแต่แรก
ใช้ conda/mamba env แยก project
ส่งงานด้วย sbatch
ดู log ก่อนสรุปว่าพัง
download output/model/log กลับมาเก็บทุกครั้ง
```
