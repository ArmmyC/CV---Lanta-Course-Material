# Makefile for LANTA workshop
# แก้ 2 บรรทัดนี้ให้ตรงกับ project ของคุณ
REMOTE_HOST ?= lanta-transfer
REMOTE_PROJECT ?= ~/projects/lpr-hackathon
LOCAL_DATA ?= ./data

.PHONY: help ssh mkdir upload-code upload-data download-output job-cpu job-gpu status

help:
	@echo "Commands:"
	@echo "  make ssh             SSH เข้า LANTA"
	@echo "  make mkdir           สร้าง project folders บน LANTA"
	@echo "  make upload-code     upload src, slurm, requirements, environment"
	@echo "  make upload-data     upload data folder"
	@echo "  make job-cpu         submit CPU job"
	@echo "  make job-gpu         submit GPU job"
	@echo "  make status          ดู job ของเรา"
	@echo "  make download-output download outputs/logs/models"

ssh:
	ssh $(REMOTE_HOST)

mkdir:
	ssh $(REMOTE_HOST) 'mkdir -p $(REMOTE_PROJECT)/{data,src,slurm,outputs,logs,models}'

upload-code:
	scp -r ./src ./slurm ./requirements.txt ./environment.yml $(REMOTE_HOST):$(REMOTE_PROJECT)/

upload-data:
	scp -r $(LOCAL_DATA)/ $(REMOTE_HOST):$(REMOTE_PROJECT)/data/

job-cpu:
	ssh $(REMOTE_HOST) 'cd $(REMOTE_PROJECT) && sbatch slurm/run_cpu.sbatch'

job-gpu:
	ssh $(REMOTE_HOST) 'cd $(REMOTE_PROJECT) && sbatch slurm/run_gpu.sbatch'

status:
	ssh $(REMOTE_HOST) 'squeue -u $$USER'

download-output:
	mkdir -p ./outputs ./logs ./models
	scp -r $(REMOTE_HOST):$(REMOTE_PROJECT)/outputs/ ./outputs/
	scp -r $(REMOTE_HOST):$(REMOTE_PROJECT)/logs/ ./logs/
	scp -r $(REMOTE_HOST):$(REMOTE_PROJECT)/models/ ./models/
