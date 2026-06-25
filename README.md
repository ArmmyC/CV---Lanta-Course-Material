<!-- prettier-ignore -->
<div align="center">

# LANTA Workshop

*คู่มือและ template สำหรับเริ่มใช้งาน LANTA กับงาน Computer Vision และ Slurm*

![SSH](https://img.shields.io/badge/SSH-LANTA-0f766e?style=flat-square)
![Slurm](https://img.shields.io/badge/Slurm-CPU%2FGPU-2563eb?style=flat-square)
![Python](https://img.shields.io/badge/Python-3.10-3776ab?style=flat-square&logo=python&logoColor=white)
![YOLO](https://img.shields.io/badge/YOLO-Ultralytics-111827?style=flat-square)

[เลือก OS](#เลือกระบบปฏิบัติการ) • [สิ่งที่จะได้เรียน](#สิ่งที่จะได้เรียน) • [Path](#path-ที่ใช้ใน-workshop-นี้) • [Workflow](#ช่วงที่-1-setup-local-machine) • [หมายเหตุ](#หมายเหตุสำคัญ)

</div>

คู่มือและ template สำหรับสอนทีมให้เริ่มใช้งาน **LANTA** สำหรับงาน Computer Vision และการส่งงานผ่าน Slurm ครอบคลุมตั้งแต่การตั้งค่า SSH, สร้าง environment, upload ไฟล์, ส่ง CPU/GPU job, ตรวจ log, และ download output กลับมาใช้งาน

> [!NOTE]
> README หลักนี้เป็นภาพรวมของ workshop ส่วนขั้นตอนละเอียดแยกตาม OS อยู่ใน [`README_Windows.md`](./README_Windows.md), [`README_Linux.md`](./README_Linux.md), และ [`README_Mac.md`](./README_Mac.md)

## เลือกระบบปฏิบัติการ

เริ่มจากคู่มือที่ตรงกับเครื่องของคุณ:

| OS | Guide | เหมาะสำหรับ |
|---|---|---|
| Windows | [Windows Guide](./README_Windows.md) | Windows Terminal, PowerShell, Git Bash |
| Linux | [Linux Guide](./README_Linux.md) | Ubuntu, Debian, Fedora และ Linux distribution อื่น ๆ |
| macOS | [macOS Guide](./README_Mac.md) | Terminal หรือ iTerm2 |

## สิ่งที่จะได้เรียน

1. SSH เข้า LANTA
2. สร้าง SSH key เพื่อไม่ต้องพิมพ์ password ทุกครั้ง
3. ตั้งค่า SSH config ให้ใช้ `ssh lanta-transfer`
4. สร้าง project folder ใน shared path
5. ตั้ง permission ที่จำเป็น
6. สร้าง Python environment ด้วย mamba/conda
7. ติดตั้ง library ด้วย `pip`
8. Upload data และ code ไป LANTA ด้วย `scp` หรือ `rsync`
9. เขียนและส่ง Slurm job สำหรับ CPU/GPU
10. ดูสถานะ job และ log
11. Download output กลับเครื่องตัวเอง

> [!IMPORTANT]
> เปลี่ยน `<USERNAME>` เป็น username ของคุณบน LANTA ทุกครั้งก่อนรันคำสั่ง
>
> Host: `transfer.lanta.nstda.or.th`  
> Alias หลังตั้งค่า SSH config: `lanta-transfer`

## Path ที่ใช้ใน workshop นี้

| ประเภท | Path |
|---|---|
| Private path | `/home/<USERNAME>` |
| Shared path รวม | `/project/zz992000-zdevb/` |
| Shared path บ้าน Pangpuriye | `/project/zz992000-zdevb/zz992005` |
| Project path ที่แนะนำ | `/project/zz992000-zdevb/zz992005/<USERNAME>/` |

ในคำสั่งด้านล่าง เราจะใช้ project path นี้เป็นหลัก:

```bash
/project/zz992000-zdevb/zz992005/<USERNAME>/test
```

> [!TIP]
> หลังเข้า LANTA แล้วสามารถใช้ `$USER` แทน username ของตัวเองได้ เช่น `/project/zz992000-zdevb/zz992005/$USER/test`

## โครงสร้าง repository ที่แนะนำ

```text
test/
├── README.md
├── README_Windows.md
├── README_Linux.md
├── README_Mac.md
├── environment.yml
├── requirements.txt
├── data/
├── models/
├── outputs/
├── logs/
├── slurm/
│   ├── run_cpu.sbatch
│   └── run_gpu.sbatch
└── src/
    ├── check_env.py
    └── train_yolo_example.py
```

| ไฟล์/โฟลเดอร์ | ใช้ทำอะไร |
|---|---|
| `environment.yml` | สร้าง conda/mamba environment ชื่อ `lanta-cv` |
| `requirements.txt` | ติดตั้ง Python packages เพิ่มเติมด้วย `pip` |
| `src/check_env.py` | ตรวจ Python, CUDA, OpenCV, Torch และ Ultralytics |
| `src/train_yolo_example.py` | ตัวอย่าง train/validate YOLO แบบสั้นสำหรับ workshop |
| `slurm/run_cpu.sbatch` | Template สำหรับส่ง CPU job |
| `slurm/run_gpu.sbatch` | Template สำหรับส่ง GPU job |
| `data/` | เก็บ dataset หรือไฟล์ input |
| `outputs/`, `logs/`, `models/` | เก็บผลลัพธ์, log และโมเดล |

### ช่วงที่ 1: Setup local machine

ให้ทุกคนทำตามไฟล์ของ OS ตัวเองก่อน:

- Windows: [README_Windows.md](./README_Windows.md)
- Linux: [README_Linux.md](./README_Linux.md)
- macOS: [README_Mac.md](./README_Mac.md)

เป้าหมายคือทุกคนต้องใช้คำสั่งนี้ได้:

```bash
ssh lanta-transfer
```

### ช่วงที่ 2: สร้าง folder บน LANTA

หลังเข้า LANTA ได้แล้ว ให้สร้าง project folder ใน shared path:

```bash
mkdir -p /project/zz992000-zdevb/zz992005/$USER/test/{data,src,slurm,outputs,logs,models}
cd /project/zz992000-zdevb/zz992005/$USER/test
pwd
```

ตรวจว่าอยู่ path ที่ถูกต้อง:

```bash
echo $USER
pwd
df -h .
```

### ช่วงที่ 3: Upload code และ data

จากเครื่องเรา ให้รันที่ root folder ของ repo นี้:

```bash
scp -r ./src ./slurm ./requirements.txt ./environment.yml lanta-transfer:/project/zz992000-zdevb/zz992005/<USERNAME>/test/
scp -r ./data/ lanta-transfer:/project/zz992000-zdevb/zz992005/<USERNAME>/test/data/
```

ถ้า data ใหญ่ แนะนำใช้ `rsync` เพื่อ resume ได้ง่ายกว่า:

```bash
rsync -avP ./data/ lanta-transfer:/project/zz992000-zdevb/zz992005/<USERNAME>/test/data/
```

### ช่วงที่ 4: สร้าง environment และส่ง job

บน LANTA:

```bash
cd /project/zz992000-zdevb/zz992005/$USER/test
mamba env create -f environment.yml
conda activate lanta-cv
pip install -r requirements.txt
```

ก่อนส่ง job ให้ตรวจ `PROJECT_DIR` ในไฟล์ `slurm/run_cpu.sbatch` และ `slurm/run_gpu.sbatch` ให้ตรงกับ project path ของคุณ:

```bash
/project/zz992000-zdevb/zz992005/$USER/test
```

ส่ง job:

```bash
sbatch slurm/run_cpu.sbatch
sbatch slurm/run_gpu.sbatch
```

ดูสถานะ job และ log:

```bash
squeue -u $USER
ls -lh logs/
```

> [!WARNING]
> ชื่อ partition, account, QOS และ GPU resource อาจต่างกันตามระบบจริง ให้เช็กด้วย `sinfo` หรือข้อมูลจากผู้ดูแล LANTA ก่อนส่งงานจริง

### ช่วงที่ 5: Download output

จากเครื่องเรา:

```bash
scp -r lanta-transfer:/project/zz992000-zdevb/zz992005/<USERNAME>/test/outputs/ ./outputs/
scp -r lanta-transfer:/project/zz992000-zdevb/zz992005/<USERNAME>/test/logs/ ./logs/
scp -r lanta-transfer:/project/zz992000-zdevb/zz992005/<USERNAME>/test/models/ ./models/
```

หรือใช้ `rsync` ถ้า output มีขนาดใหญ่:

```bash
rsync -avP lanta-transfer:/project/zz992000-zdevb/zz992005/<USERNAME>/test/outputs/ ./outputs/
```

## หมายเหตุสำคัญ

- ใช้ SSH config เพื่อให้คำสั่งสั้นเหลือแค่ `ssh lanta-transfer`
- ใช้ `<USERNAME>` บนเครื่องตัวเอง และใช้ `$USER` เมื่ออยู่บน LANTA
- ตรวจ `PROJECT_DIR` ใน Slurm script ก่อน `sbatch` ทุกครั้ง
- ตรวจ partition และ resource จริงก่อนส่ง job:

```bash
sinfo
squeue -u $USER
```

- ถ้า GPU job ไม่เริ่ม ให้เช็ก queue, QOS, account และ resource limit ของ project ก่อน
