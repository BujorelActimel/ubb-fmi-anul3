from random import randint

N = 1000
LIMIT = 49

with open("input2.txt", "w") as f:
    f.write(f"{N}\n")
    for _ in range(N):
        for _ in range(N):
            f.write(f"{randint(0, LIMIT)} ")
        f.write("\n")
