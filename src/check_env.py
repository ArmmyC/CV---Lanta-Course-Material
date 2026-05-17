import sys
import platform

print("Python:", sys.version)
print("Platform:", platform.platform())

try:
    import torch
    print("PyTorch:", torch.__version__)
    print("CUDA available:", torch.cuda.is_available())
    if torch.cuda.is_available():
        print("GPU:", torch.cuda.get_device_name(0))
except Exception as e:
    print("PyTorch check skipped/error:", e)

try:
    import cv2
    print("OpenCV:", cv2.__version__)
except Exception as e:
    print("OpenCV check skipped/error:", e)

try:
    import ultralytics
    print("Ultralytics:", ultralytics.__version__)
except Exception as e:
    print("Ultralytics check skipped/error:", e)
