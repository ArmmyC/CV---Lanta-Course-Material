# LANTA Workshop

คู่มือนี้ใช้สำหรับสอนทีมให้ใช้งาน **LANTA**

## เลือกระบบปฏิบัติการ

- [Windows Guide](./README_Windows.md)
- [Linux Guide](./README_Linux.md)
- [macOS Guide](./README_Mac.md)

## สิ่งที่จะได้เรียน

1. SSH เข้า LANTA
2. สร้าง SSH key เพื่อไม่ต้องพิมพ์ password ทุกครั้ง
3. ตั้งค่า SSH config ให้ใช้ `ssh lanta-transfer`
4. สร้าง project folder ใน shared path
5. ตั้ง permission ที่จำเป็น
6. สร้าง Python environment ด้วย mamba/conda
7. ติดตั้ง library ด้วย pip
8. upload data/code ไป LANTA ด้วย `scp`
9. เขียนและส่ง Slurm job สำหรับ CPU/GPU
10. ดูสถานะ job และ log
11. download output กลับเครื่องตัวเอง

> เปลี่ยน `<USERNAME>` เป็น username ของคุณบน LANTA  
> Host: `transfer.lanta.nstda.or.th`  
> Alias ที่จะใช้หลังตั้งค่า SSH config: `lanta-transfer`

## Path ที่ใช้ใน workshop นี้

| ประเภท | Path |
|---|---|
| Private path | `/home/<USERNAME>` |
| Shared path รวม | `/project/992000-zdevb/` |
| Shared path บ้าน Pangpuriye | `/project/992000-zdevb/zz992005` |
| Project path ที่แนะนำ | `/project/992000-zdevb/zz992005/<USERNAME>/` |

ในคำสั่งด้านล่าง เราจะใช้ project path นี้เป็นหลัก:

```bash
/project/992000-zdevb/zz992005/<USERNAME>/test
```


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
mkdir -p /project/992000-zdevb/zz992005/$USER/test/{data,src,slurm,outputs,logs,models}
cd /project/992000-zdevb/zz992005/$USER/test
pwd
```

### ช่วงที่ 3: Upload code และ data

จากเครื่องเรา:

```bash
scp -r ./src ./slurm ./requirements.txt ./environment.yml lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/
scp -r ./data/ lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/data/
```

### ช่วงที่ 4: สร้าง environment และส่ง job

บน LANTA:

```bash
cd /project/992000-zdevb/zz992005/$USER/test
mamba env create -f environment.yml
conda activate lanta-cv
pip install -r requirements.txt
sbatch slurm/run_cpu.sbatch
sbatch slurm/run_gpu.sbatch
```

### ช่วงที่ 5: Download output

จากเครื่องเรา:

```bash
scp -r lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/outputs/ ./outputs/
scp -r lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/logs/ ./logs/
scp -r lanta-transfer:/project/992000-zdevb/zz992005/<USERNAME>/test/models/ ./models/
```

## หมายเหตุสำคัญ

- ใช้ SSH config เพื่อให้สั้นเหลือแค่ `ssh lanta-transfer`
- ชื่อ partition ใน Slurm เช่น `cpu` และ `gpu` เป็น template ให้เช็กของจริงด้วย:

```bash
sinfo
squeue -u $USER
```

