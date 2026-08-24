import torch

def main():
    x = torch.tensor([1.0, 2.0, 3.0])
    print(f"Sum: {x.sum().item()}")

if __name__ == "__main__":
    main()
