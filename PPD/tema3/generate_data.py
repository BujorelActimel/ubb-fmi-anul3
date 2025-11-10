import random
import os

def generate_number(length):
    digits = [str(random.randint(1, 9))]
    for _ in range(length - 1):
        digits.append(str(random.randint(0, 9)))
    return ''.join(digits)

def write_number(filename, number):
    with open(filename, 'w') as f:
        f.write(f"{len(number)}\n")
        f.write(number)
    print(f"Generated {filename}: {len(number)} digits")

def main():
    os.makedirs('data', exist_ok=True)

    write_number('data/N1_10000.txt', generate_number(10000))
    write_number('data/N2_10000.txt', generate_number(10000))

    write_number('data/N1_100.txt', generate_number(100))
    write_number('data/N2_100000.txt', generate_number(100000))

    write_number('data/N1_1000.txt', generate_number(1000))
    write_number('data/N2_1000.txt', generate_number(1000))

if __name__ == "__main__":
    main()
