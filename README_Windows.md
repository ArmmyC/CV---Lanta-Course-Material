# README Windows: ใช้ LANTA สำหรับ Computer Vision Hackathon

คู่มือนี้เหมาะกับ Windows 10/11 โดยแนะนำให้ใช้ **Windows Terminal + PowerShell** หรือ **Git Bash**

> เปลี่ยน `<USERNAME>` เป็น username ของคุณบน LANTA  
> Host: `transfer.lanta.nstda.or.th`  
> Alias ที่จะใช้หลังตั้งค่า SSH config: `lanta-transfer`

## Path ที่ใช้ใน workshop นี้

| ประเภท                      | Path                                        |
| --------------------------- | ------------------------------------------- |
| Private path                | `/home/<USERNAME>`                          |
| Shared path รวม             | `/project/992000-zdevb/`                    |
| Shared path บ้าน Pangpuriye | `/project/992000-zdevb/zz992005`            |
| Project path ที่แนะนำ       | `/project/992000-zdevb/zz992005/<USERNAME>` |

ในคำสั่งด้านล่าง เราจะใช้ project path นี้เป็นหลัก:

```bash
/project/992000-zdevb/zz992005/<USERNAME>/test
```

## 0. สิ่งที่ต้องมีบน Windows

แนะนำติดตั้ง:

- Windows Terminal
- Git for Windows เพื่อใช้ Git Bash และ `git`
- VS Code
- OpenSSH Client, ปกติ Windows 10/11 มีมาให้แล้ว

ตรวจใน PowerShell:

```powershell
ssh -V
git --version
```

ถ้าใช้ Git Bash ให้เปิด Git Bash แล้วตรวจ:

```bash
ssh -V
git --version
```

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

---

## 2. สร้าง SSH key เพื่อไม่ต้องพิมพ์ password ทุกครั้ง

สร้าง key ใน PowerShell:

```powershell
ssh-keygen -t ed25519 -C "lanta" -f $env:USERPROFILE\.ssh\lanta_ed25519
```

กด Enter ตามขั้นตอน แนะนำให้ตั้ง passphrase

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

จากนี้ให้ใช้คำสั่งสั้น ๆ ได้เลย:

```powershell
ssh lanta-transfer
```

---

## 4. สร้าง project folder บน LANTA

เข้า LANTA:

```powershell
ssh lanta-transfer
```

บน LANTA:

```bash
mkdir -p /project/992000-zdevb/zz992005/$USER/test/{data,src,slurm,outputs,logs,models}
cd /project/992000-zdevb/zz992005/$USER/test
pwd
ls -la
```

ถ้าอยากเช็กว่าอยู่ shared path ถูกไหม:

```bash
echo $USER
pwd
df -h .
```

---

## 5. Permission ที่ควรรู้: chmod

บน LANTA:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod +x src/*.py 2>/dev/null || true
```

ความหมายสั้น ๆ:

| Command                            | ใช้ทำอะไร                                   |
| ---------------------------------- | ------------------------------------------- |
| `chmod 700 ~/.ssh`                 | ให้เจ้าของอ่าน/เขียน/เข้า folder ได้คนเดียว |
| `chmod 600 ~/.ssh/authorized_keys` | ให้เจ้าของอ่าน/เขียน key file ได้คนเดียว    |
| `chmod +x src/*.py`                | ทำให้ Python script execute ได้             |

---

## 6. Upload ไฟล์ template ไป LANTA

ให้เปิด PowerShell ที่ root folder ของ repo นี้ แล้วรัน:

```powershell
scp .\requirements.txt lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/
scp .\environment.yml lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/
scp -r .\src\ lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/
scp -r .\slurm\ lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/
```

ถ้าไม่มี `requirements.txt` หรือ `environment.yml` ให้ข้ามสองบรรทัดแรก แล้วไปสร้าง environment และติดตั้ง library เองในหัวข้อ 9-10

ถ้าใช้ Git Bash:

```bash
scp ./requirements.txt lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/
scp ./environment.yml lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/
scp -r ./src/ ./slurm/ lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/
```

ถ้าใช้ Git Bash และไม่มีสองไฟล์นี้ ให้ข้ามสองบรรทัดแรกเช่นกัน

---

## 7. Upload data ไป LANTA ด้วย scp

PowerShell:

```powershell
scp -r .\data\ lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/data/
```

Git Bash:

```bash
scp -r ./data/ lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/data/
```

ถ้า data ใหญ่มาก แนะนำ zip ก่อน:

```powershell
Compress-Archive -Path .\data\* -DestinationPath data.zip
scp .\data.zip lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/
```

บน LANTA:

```bash
cd /project/992000-zdevb/zz992005/$USER/test
unzip data.zip -d data
```

---

## 8. Upload ไฟล์ `.py` หรือ `.ipynb`

PowerShell:

```powershell
scp .\src\train.py lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/src/
scp .\notebooks\experiment.ipynb lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/src/
```

บน LANTA เช็กไฟล์:

```bash
ls -lh /project/992000-zdevb/zz992005/$USER/test/src/
```

หมายเหตุ: บน HPC มักนิยมรัน `.py` ผ่าน Slurm มากกว่า `.ipynb` ถ้ามี notebook ให้ export เป็น Python script ก่อน

---

## 9. สร้าง environment ด้วย mamba/conda

บน LANTA:

```bash
cd /project/992000-zdevb/zz992005/$USER/test
mamba --version || true
conda --version || true
```

### กรณีมีไฟล์ `environment.yml`

ถ้ามี `mamba`:

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

### กรณีไม่มีไฟล์ `environment.yml`

ให้สร้าง environment เองด้วยชื่อเดียวกับใน workshop:

```bash
mamba create -n lanta-cv python=3.10 pip -y
```

ถ้าไม่มี `mamba`:

```bash
conda create -n lanta-cv python=3.10 pip -y
```

จากนั้น activate:

```bash
conda activate lanta-cv
```

ติดตั้ง library พื้นฐานที่ conda จัดการได้ดี:

```bash
mamba install -c conda-forge numpy pandas matplotlib scikit-learn tqdm pillow pyyaml -y
```

ถ้าไม่มี `mamba`:

```bash
conda install -c conda-forge numpy pandas matplotlib scikit-learn tqdm pillow pyyaml -y
```

---

## 10. ติดตั้ง library ด้วย pip

บน LANTA หลัง activate env:

### กรณีมีไฟล์ `requirements.txt`

```bash
pip install -r requirements.txt
```

### กรณีไม่มีไฟล์ `requirements.txt`

ให้พิมพ์ชื่อ library ที่ต้องใช้เอง:

```bash
pip install ultralytics opencv-python pandas matplotlib tqdm scikit-learn pillow pyyaml
```

ถ้าต้องการบันทึกรายการ library ที่ติดตั้งไว้ใช้ซ้ำภายหลัง:

```bash
pip freeze > requirements.txt
```

เช็กว่า import ได้ไหม:

```bash
python -c "import cv2, pandas, ultralytics; print('OK')"
```

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

PROJECT_DIR="/project/992000-zdevb/zz992005/${USER}/test"
cd "$PROJECT_DIR"

source ~/.bashrc
conda activate lanta-cv

python src/check_env.py
```

คำอธิบายทีละบรรทัด:

| บรรทัด                            | ความหมาย                                                        |
| --------------------------------- | --------------------------------------------------------------- |
| `#!/bin/bash`                     | บอกระบบให้รันไฟล์นี้ด้วย Bash shell                             |
| `#SBATCH --job-name=cv_cpu_test`  | ตั้งชื่อ job ให้ดูง่ายใน `squeue` และชื่อ log                   |
| `#SBATCH --partition=cpu`         | ขอส่งงานเข้า CPU partition                                      |
| `#SBATCH --nodes=1`               | ขอใช้ compute node 1 เครื่อง                                    |
| `#SBATCH --ntasks=1`              | รัน task หลัก 1 task เหมาะกับ Python script ทั่วไป              |
| `#SBATCH --cpus-per-task=4`       | ให้ task นี้ใช้ CPU ได้ 4 cores                                 |
| `#SBATCH --mem=16G`               | ขอ RAM 16 GB                                                    |
| `#SBATCH --time=01:00:00`         | จำกัดเวลารันสูงสุด 1 ชั่วโมง                                    |
| `#SBATCH --output=logs/%x-%j.out` | เก็บ stdout ใน `logs/` โดย `%x` คือชื่อ job และ `%j` คือ job id |
| `#SBATCH --error=logs/%x-%j.err`  | เก็บ stderr หรือ error log ใน `logs/`                           |
| `set -e`                          | ถ้าคำสั่งใด fail ให้หยุด job ทันที                              |
| `PROJECT_DIR=...`                 | กำหนด path โปรเจกต์บน shared storage                            |
| `cd "$PROJECT_DIR"`               | เข้า folder โปรเจกต์ก่อนรันงาน                                  |
| `source ~/.bashrc`                | โหลด shell config เพื่อให้ใช้ `conda activate` ได้              |
| `conda activate lanta-cv`         | เปิด conda environment ที่เตรียมไว้                             |
| `python src/check_env.py`         | รัน script สำหรับตรวจ environment                               |

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

PROJECT_DIR="/project/992000-zdevb/zz992005/${USER}/test"
cd "$PROJECT_DIR"

source ~/.bashrc
conda activate lanta-cv

python src/check_env.py
python src/train_yolo_example.py
```

คำอธิบายทีละบรรทัด:

| บรรทัด                             | ความหมาย                                                         |
| ---------------------------------- | ---------------------------------------------------------------- |
| `#!/bin/bash`                      | บอกระบบให้รันไฟล์นี้ด้วย Bash shell                              |
| `#SBATCH --job-name=cv_gpu_train`  | ตั้งชื่อ job สำหรับงาน train ด้วย GPU                            |
| `#SBATCH --partition=gpu`          | ขอส่งงานเข้า GPU partition                                       |
| `#SBATCH --nodes=1`                | ขอใช้ compute node 1 เครื่อง                                     |
| `#SBATCH --ntasks=1`               | รัน task หลัก 1 task                                             |
| `#SBATCH --cpus-per-task=8`        | ให้ task นี้ใช้ CPU ได้ 8 cores เพื่อช่วยโหลดข้อมูล/เตรียม batch |
| `#SBATCH --mem=32G`                | ขอ RAM 32 GB                                                     |
| `#SBATCH --gres=gpu:1`             | ขอ GPU 1 ใบ                                                      |
| `#SBATCH --time=04:00:00`          | จำกัดเวลารันสูงสุด 4 ชั่วโมง                                     |
| `#SBATCH --output=logs/%x-%j.out`  | เก็บ stdout ใน `logs/` โดย `%x` คือชื่อ job และ `%j` คือ job id  |
| `#SBATCH --error=logs/%x-%j.err`   | เก็บ stderr หรือ error log ใน `logs/`                            |
| `set -e`                           | ถ้าคำสั่งใด fail ให้หยุด job ทันที                               |
| `PROJECT_DIR=...`                  | กำหนด path โปรเจกต์บน shared storage                             |
| `cd "$PROJECT_DIR"`                | เข้า folder โปรเจกต์ก่อนรันงาน                                   |
| `source ~/.bashrc`                 | โหลด shell config เพื่อให้ใช้ `conda activate` ได้               |
| `conda activate lanta-cv`          | เปิด conda environment ที่เตรียมไว้                              |
| `python src/check_env.py`          | ตรวจ Python, library, และ GPU ก่อนเริ่ม train                    |
| `python src/train_yolo_example.py` | รัน training script ตัวอย่าง                                     |

ส่ง job:

```bash
sbatch slurm/run_gpu.sbatch
```

ถ้า partition ไม่ใช่ `gpu` ให้เช็กด้วย:

```bash
sinfo
```

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
scp -r lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/outputs/ .\outputs\
scp -r lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/logs/ .\logs\
scp -r lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/models/ .\models\
```

Git Bash:

```bash
scp -r lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/outputs/ ./outputs/
scp -r lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/logs/ ./logs/
scp -r lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/models/ ./models/
```

---

## 15. Computer Vision workflow บน LANTA

สำหรับ license plate / object detection:

```text
local machine
→ เตรียม dataset
→ upload data ไป LANTA shared path
→ train YOLO ด้วย Slurm GPU
→ save model best.pt ใน models/
→ run inference
→ save annotated images ใน outputs/
→ download outputs กลับมา
```

สิ่งที่ควรให้ทีมดูใน job log:

```bash
python -c "import torch; print(torch.cuda.is_available())"
nvidia-smi || true
```

บางครั้ง login node อาจไม่มี GPU ให้เช็ก GPU ใน job log ของ Slurm แทน

---

## 16. Troubleshooting Windows

| ปัญหา                           | วิธีแก้                                                                               |
| ------------------------------- | ------------------------------------------------------------------------------------- |
| `ssh` ใช้ไม่ได้                 | เปิด Optional Features แล้วติดตั้ง OpenSSH Client หรือใช้ Git Bash                    |
| `Permission denied (publickey)` | เช็ก path key ใน `~/.ssh/config`, เช็ก `authorized_keys` บน LANTA                     |
| `scp` path ผิด                  | PowerShell ใช้ `.\folder\file`, Git Bash ใช้ `./folder/file`                          |
| upload ช้ามาก                   | zip data ก่อน หรือใช้ `rsync` ถ้ามีใน Git Bash                                        |
| conda activate ไม่ได้           | ลอง `source ~/.bashrc` แล้ว `conda activate lanta-cv`                                 |
| job pending                     | เช็ก `squeue`, `sinfo`, partition, quota, time limit                                  |
| `No such file or directory`     | เช็กว่า path เป็น `/project/992000-zdevb/zz992005/$USER/test` ไม่ใช่ `~/projects/...` |

---

## 17. Cheat Sheet Windows

PowerShell:

```powershell
ssh <USERNAME>@transfer.lanta.nstda.or.th
ssh-keygen -t ed25519 -C "lanta" -f $env:USERPROFILE\.ssh\lanta_ed25519
notepad $env:USERPROFILE\.ssh\config
ssh lanta-transfer
scp -r .\data\ lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/data/
scp -r lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/outputs/ .\outputs\
```

บน LANTA:

```bash
mkdir -p /project/992000-zdevb/zz992005/$USER/test/{data,src,slurm,outputs,logs,models}
cd /project/992000-zdevb/zz992005/$USER/test
mamba env create -f environment.yml
conda activate lanta-cv
pip install -r requirements.txt
sbatch slurm/run_cpu.sbatch
sbatch slurm/run_gpu.sbatch
squeue -u $USER
tail -f logs/<LOG_FILE>.out
```
