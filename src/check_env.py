import os
import sys
import platform

print("Python executable:", sys.executable)
print("Python version:", sys.version)
print("Platform:", platform.platform())
print("Current working directory:", os.getcwd())

try:
    import torch
    print("torch:", torch.__version__)
    print("CUDA available:", torch.cuda.is_available())
    if torch.cuda.is_available():
        print("CUDA device count:", torch.cuda.device_count())
        print("CUDA device name:", torch.cuda.get_device_name(0))
except Exception as exc:
    print("torch check failed:", repr(exc))

try:
    import cv2
    print("opencv:", cv2.__version__)
except Exception as exc:
    print("opencv check failed:", repr(exc))

try:
    import ultralytics
    print("ultralytics:", ultralytics.__version__)
except Exception as exc:
    print("ultralytics check failed:", repr(exc))

print("Environment check finished.")
