import random
import sys

def generate_test_file(n, m, k, filename="date.txt"):    
    with open(filename, 'w') as f:
        f.write(f"{n} {m} {k}\n")
        
        for i in range(n):
            row = [str(random.randint(0, 100)) for _ in range(m)]
            f.write(" ".join(row) + "\n")
        
        center = k // 2
        for i in range(k):
            row = []
            for j in range(k):
                if i == center and j == center:
                    row.append("1")
                else:
                    row.append("0")
            f.write(" ".join(row) + "\n")
    
    print(f"Generated: {filename} (F={n}x{m}, C={k}x{k})")


if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python generate-input.py <n> <m> <k> [filename]")
        print("Ex: python generate-input.py 1000 1000 5 date.txt")
        sys.exit(1)
    
    n = int(sys.argv[1])
    m = int(sys.argv[2])
    k = int(sys.argv[3])
    filename = sys.argv[4] if len(sys.argv) > 4 else "date.txt"
    
    try:
        assert(k % 2 != 0)
    except:
        print("k must be an odd number")

    generate_test_file(n, m, k, filename)
