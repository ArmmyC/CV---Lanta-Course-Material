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
