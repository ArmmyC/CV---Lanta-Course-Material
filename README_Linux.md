# README Linux: ใช้ LANTA สำหรับ Computer Vision Hackathon

คู่มือนี้เหมาะกับ Ubuntu, Debian, Fedora และ Linux distribution อื่น ๆ ที่มี `ssh` และ `scp`

> เปลี่ยน `<USERNAME>` เป็น username ของคุณบน LANTA  
> Host: `transfer.lanta.nstda.or.th`  
> Alias ที่จะใช้หลังตั้งค่า SSH config: `lanta-transfer`

## Path ที่ใช้ใน workshop นี้

| ประเภท | Path |
|---|---|
| Private path | `/home/<USERNAME>` |
| Shared path รวม | `/project/992000-zdevb/` |
| Shared path บ้าน Pangpuriye | `/project/992000-zdevb/zz992005` |
| Project path ที่แนะนำ | `/project/992000-zdevb/zz992005/<USERNAME>/test` |

ในคำสั่งด้านล่าง เราจะใช้ project path นี้เป็นหลัก:

```bash
/project/992000-zdevb/zz992005/<USERNAME>/test
```


## 0. สิ่งที่ต้องมีบน Linux

ตรวจว่าเครื่องมีคำสั่งพื้นฐาน:

```bash
ssh -V
scp -V 2>/dev/null || true
git --version
```

ถ้ายังไม่มี OpenSSH client:

Ubuntu/Debian:

```bash
sudo apt update
sudo apt install -y openssh-client git
```

Fedora:

```bash
sudo dnf install -y openssh-clients git
```

---

## 1. SSH เข้า LANTA ครั้งแรก

```bash
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

```bash
ssh-keygen -t ed25519 -C "lanta" -f ~/.ssh/lanta_ed25519
```

ดู public key:

```bash
cat ~/.ssh/lanta_ed25519.pub
```

เพิ่ม public key ไปที่ LANTA:

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
```

ทดสอบ:

```bash
ssh lanta-transfer
```

---

## 4. สร้าง project folder บน LANTA

```bash
ssh lanta-transfer
```

บน LANTA:

```bash
mkdir -p /project/992000-zdevb/zz992005/$USER/test/{data,src,slurm,outputs,logs,models}
cd /project/992000-zdevb/zz992005/$USER/test
pwd
ls -la
```

---

## 5. Permission ที่ควรรู้: chmod

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod +x src/*.py 2>/dev/null || true
```

---

## 6. Upload ไฟล์ template ไป LANTA

จากเครื่องเรา:

```bash
scp ./requirements.txt lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/
scp ./environment.yml lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/
scp -r ./src/ ./slurm/ lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/
```

---

## 7. Upload data ไป LANTA ด้วย scp

```bash
scp -r ./data/ lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/data/
```

ถ้า data ใหญ่มาก:

```bash
zip -r data.zip data/
scp data.zip lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/
```

บน LANTA:

```bash
cd /project/992000-zdevb/zz992005/$USER/test
unzip data.zip -d .
```

ถ้ามี `rsync` ใช้แบบ resume ได้ดีกว่า:

```bash
rsync -avP ./data/ lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/data/
```

---

## 8. Upload ไฟล์ `.py` หรือ `.ipynb`

```bash
scp ./src/train.py lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/src/
scp ./notebooks/experiment.ipynb lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/src/
```

บน LANTA:

```bash
ls -lh /project/992000-zdevb/zz992005/$USER/test/src/
```

---

## 9. สร้าง environment ด้วย mamba/conda

บน LANTA:

```bash
cd /project/992000-zdevb/zz992005/$USER/test
mamba --version || true
conda --version || true
```

ถ้ามี mamba:

```bash
mamba env create -f environment.yml
```

ถ้าไม่มี:

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

## 10. ติดตั้ง library ด้วย pip

```bash
pip install -r requirements.txt
python -c "import cv2, pandas, ultralytics; print('OK')"
```

---

## 11. ส่ง Slurm job แบบ CPU

```bash
cd /project/992000-zdevb/zz992005/$USER/test
sbatch slurm/run_cpu.sbatch
```

Template อยู่ที่ `slurm/run_cpu.sbatch`

---

## 12. ส่ง Slurm job แบบ GPU

```bash
cd /project/992000-zdevb/zz992005/$USER/test
sbatch slurm/run_gpu.sbatch
```

ถ้า partition ไม่ตรง ให้เช็ก:

```bash
sinfo
```

---

## 13. ดูสถานะ job, log, cancel job

```bash
squeue -u $USER
sinfo
ls -lh logs/
tail -f logs/cv_gpu_train-<JOB_ID>.out
scancel <JOB_ID>
```

---

## 14. Download output กลับ Linux

```bash
scp -r lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/outputs/ ./outputs/
scp -r lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/logs/ ./logs/
scp -r lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/models/ ./models/
```

หรือใช้ rsync:

```bash
rsync -avP lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/outputs/ ./outputs/
```

---

## 15. Computer Vision workflow บน LANTA

```text
local machine
→ เตรียม dataset
→ upload data ไป shared path
→ train YOLO ด้วย Slurm GPU
→ save model best.pt ใน models/
→ run inference
→ save annotated images ใน outputs/
→ download outputs กลับมา
```

เช็ก CUDA ใน job log:

```bash
python -c "import torch; print(torch.cuda.is_available())"
nvidia-smi || true
```

---

## 16. Troubleshooting Linux

| ปัญหา | วิธีแก้ |
|---|---|
| `Permission denied (publickey)` | เช็ก `~/.ssh/config`, key file, และ `authorized_keys` |
| `Bad permissions` | รัน `chmod 700 ~/.ssh && chmod 600 ~/.ssh/config ~/.ssh/lanta_ed25519` |
| upload ช้ามาก | ใช้ `rsync -avP` หรือ zip data ก่อน |
| job pending | เช็ก `squeue`, `sinfo`, partition, quota, time limit |
| conda activate ไม่ได้ | ลอง `source ~/.bashrc` แล้ว `conda activate lanta-cv` |
| path ไม่เจอ | ใช้ `/project/992000-zdevb/zz992005/$USER/test` |

---

## 17. Cheat Sheet Linux

```bash
ssh <USERNAME>@transfer.lanta.nstda.or.th
ssh-keygen -t ed25519 -C "lanta" -f ~/.ssh/lanta_ed25519
nano ~/.ssh/config
ssh lanta-transfer
scp -r ./data/ lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/data/
scp -r lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/outputs/ ./outputs/
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
```
