matrix = []

with open("input2.txt", "r") as f:
    lines = f.readlines()[1:]
    for line in lines:
        nums = list(map(int, line.strip().split()))
        matrix.append(nums)

with open("test-output.txt", "w") as f:
    for line in matrix:
        f.write(f"{sum(line)} ")
