import os
import platform
import sys

print("=== Environment Check ===")
print("Python:", sys.version)
print("Executable:", sys.executable)
print("Platform:", platform.platform())
print("Working directory:", os.getcwd())

try:
    import torch
    print("torch:", torch.__version__)
    print("cuda available:", torch.cuda.is_available())
    if torch.cuda.is_available():
        print("gpu:", torch.cuda.get_device_name(0))
except Exception as e:
    print("torch check failed:", repr(e))

for pkg in ["cv2", "numpy", "pandas", "ultralytics"]:
    try:
        mod = __import__(pkg)
        print(f"{pkg}: OK")
    except Exception as e:
        print(f"{pkg}: missing or failed: {e}")
