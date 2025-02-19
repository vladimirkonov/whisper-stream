import torch

print(torch.__version__)

device = "cuda" if torch.cuda.is_available() else "cpu"

print(device)