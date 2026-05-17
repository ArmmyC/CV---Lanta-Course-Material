# Workshop: ใช้ LANTA สำหรับ Computer Vision Hackathon

เอกสารชุดนี้แยกตามระบบปฏิบัติการ เพื่อให้ทีมกดตามได้ง่ายระหว่าง workshop

> เปลี่ยน `<USERNAME>` เป็น username ของแต่ละคนก่อนรัน command  
> Host ตัวอย่าง: `transfer.lanta.nstda.or.th`  
> ชื่อ partition/account ของ LANTA อาจต่างจาก template ให้เช็กด้วย `sinfo`, `squeue`, `sacctmgr` หรือถาม TA/ผู้ดูแลระบบ

## เลือกคู่มือของคุณ

| ระบบ    | ไฟล์                                   |
| ------- | -------------------------------------- |
| Windows | [README_Windows.md](README_Windows.md) |
| Linux   | [README_Linux.md](README_Linux.md)     |
| macOS   | [README_Mac.md](README_Mac.md)         |

## ไฟล์ template ที่ให้มา

| ไฟล์                                                   | ใช้ทำอะไร                                                              |
| ------------------------------------------------------ | ---------------------------------------------------------------------- |
| [Makefile](Makefile)                                   | รวม command สั้น ๆ เช่น `make ssh`, `make upload-code`, `make job-gpu` |
| [environment.yml](environment.yml)                     | สร้าง conda/mamba environment                                          |
| [requirements.txt](requirements.txt)                   | ติดตั้ง Python libraries ด้วย pip                                      |
| [slurm/run_cpu.sbatch](slurm/run_cpu.sbatch)           | Template สำหรับส่งงาน CPU                                              |
| [slurm/run_gpu.sbatch](slurm/run_gpu.sbatch)           | Template สำหรับส่งงาน GPU                                              |
| [src/check_env.py](src/check_env.py)                   | Script ทดสอบ environment                                               |
| [src/train_yolo_example.py](src/train_yolo_example.py) | ตัวอย่าง script สำหรับงาน Computer Vision / YOLO                       |

## Flow ที่จะสอน

```text
เครื่องเรา
→ SSH เข้า LANTA transfer/login node
→ สร้าง SSH key และ config
→ สร้าง project folder
→ สร้าง Python environment
→ upload data/code ด้วย scp
→ submit job ด้วย Slurm
→ ดู log และผลลัพธ์
→ download output กลับเครื่องเรา
```

## สิ่งสำคัญ

- อย่ารัน train model หนัก ๆ บน transfer/login node โดยตรง
- งาน train/inference หนักให้ส่งผ่าน Slurm
- Private key ห้ามส่งให้ใคร
- ตั้งชื่อ folder ให้ชัด เช่น `~/projects/lpr-hackathon`
- เก็บ `data/`, `src/`, `slurm/`, `outputs/`, `logs/` แยกกัน
- เริ่มจาก script เล็ก ๆ เช่น `check_env.py` ก่อน train model จริง

## โครงสร้าง project ที่แนะนำบน LANTA

```text
~/projects/lpr-hackathon/
├── data/
├── src/
├── slurm/
├── outputs/
├── logs/
├── models/
├── requirements.txt
└── environment.yml
```

## Workflow สำหรับ Computer Vision บน LANTA

```text
1. เตรียม dataset บนเครื่องเรา
2. upload dataset ไป LANTA ด้วย scp หรือ rsync
3. สร้าง environment ด้วย mamba/conda
4. ติดตั้ง library เช่น ultralytics, opencv-python, pandas
5. รัน check_env.py ด้วย Slurm CPU ก่อน
6. รัน train/inference ด้วย Slurm GPU
7. ดู log ใน logs/
8. เก็บผลลัพธ์ใน outputs/
9. download outputs กลับเครื่องเรา
```

## Computer Vision

- ตรวจว่า GPU ใช้ได้ไหม
- โหลด YOLO model ได้ไหม
- อ่านรูปด้วย OpenCV ได้ไหม
- predict รูปตัวอย่างได้ไหม
- output ถูกบันทึกใน `outputs/` ไหม
- job ใช้ GPU จริงหรือเปล่า

## Slurm command ที่ใช้บ่อย

```bash
sinfo
squeue -u $USER
sbatch slurm/run_cpu.sbatch
sbatch slurm/run_gpu.sbatch
scancel <JOB_ID>
tail -f logs/<LOG_FILE>.out
```
