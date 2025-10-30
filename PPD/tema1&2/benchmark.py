#!/usr/bin/env python3

import subprocess
import os
import sys
from datetime import datetime

NUM_RUNS = 1
CPP_EXECUTABLE = "./cpp/build/convolution"
JAVA_BUILD_DIR = "./java/build"
JAVA_MAIN = "Convolution"

LAB1_CONFIGS = [
    {"n": 10, "m": 10, "k": 3, "threads": [4]},
    {"n": 1000, "m": 1000, "k": 5, "threads": [1, 2, 4, 8, 16]},
    {"n": 10, "m": 10000, "k": 5, "threads": [2, 4, 8, 16]},
    {"n": 10000, "m": 10, "k": 5, "threads": [2, 4, 8, 16]},
]

LAB1_STRATEGIES = ["horizontal", "vertical", "block"]

LAB2_CONFIGS = [
    {"n": 10, "m": 10, "k": 3, "threads": [0, 2]},
    {"n": 1000, "m": 1000, "k": 3, "threads": [0, 2, 4, 8, 16]},
    {"n": 10000, "m": 10000, "k": 3, "threads": [0, 2, 4, 8, 16]},
]


def generate_input(n, m, k):
    filename = f"data/test_{n}x{m}_{k}.txt"
    os.makedirs("data", exist_ok=True)

    if not os.path.exists(filename):
        subprocess.run(["python3", "generate-input.py", str(n), str(m), str(k), filename],
                      capture_output=True)
    return filename


def compile_all():
    result = subprocess.run(["make", "-C", "cpp"], capture_output=True, text=True)
    if result.returncode != 0:
        print("C++ compilation failed!")
        print(result.stderr)
        return False
    print("C++ compiled")

    result = subprocess.run(["make", "-C", "java"], capture_output=True, text=True)
    if result.returncode != 0:
        print("Java compilation failed!")
        print(result.stderr)
        return False
    print("Java compiled")

    print()
    return True


def verify_output(expected_file, actual_file, label):
    try:
        result = subprocess.run(["diff", expected_file, actual_file],
                              capture_output=True, text=True)
        if result.returncode == 0:
            print(f"{label} verified")
            return True
        else:
            print(f"{label} MISMATCH!")
            return False
    except:
        print(f"{label} verification failed")
        return False


def run_cpp_test(input_file, mode, threads=None, strategy="horizontal", inplace=False):
    times = []
    sequential_output = "output_seq_cpp.txt"
    test_output = "output_test_cpp.txt"

    for run in range(NUM_RUNS):
        cmd = [CPP_EXECUTABLE, "-i", input_file, "-e", mode]

        if inplace:
            cmd.append("--inplace")

        if mode == "par":
            cmd.extend(["-t", str(threads)])
            if not inplace:
                cmd.extend(["-s", strategy])

        if run == 0:
            if threads is None or threads == 0:
                cmd.extend(["-o", sequential_output])
            else:
                cmd.extend(["-o", test_output])
        else:
            cmd.extend(["-o", "output_tmp.txt"])

        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)

            found_time = False
            for line in result.stdout.split('\n'):
                if "Convolution time:" in line:
                    time_str = line.split(':')[1].strip().split()[0]
                    time_ms = int(time_str)
                    times.append(time_ms)
                    found_time = True
                    break

            if not found_time and run == 0:
                print(f"WARNING: No time found in C++ output")

        except Exception as e:
            if run == 0:
                print(f"ERROR: {e}")
            continue

    if times and (threads is not None and threads > 0):
        verify_output(sequential_output, test_output, "C++")

    if times:
        return sum(times) / len(times)
    return None


def run_java_test(input_file, mode, threads=None, strategy="horizontal", inplace=False):
    times = []
    sequential_output = "output_seq_java.txt"
    test_output = "output_test_java.txt"

    for run in range(NUM_RUNS):
        cmd = ["java", "-cp", JAVA_BUILD_DIR, JAVA_MAIN, "-i", input_file, "-e", mode]

        if inplace:
            cmd.append("--inplace")

        if mode == "par":
            cmd.extend(["-t", str(threads)])
            if not inplace:
                cmd.extend(["-s", strategy])

        if run == 0:
            if threads is None or threads == 0:
                cmd.extend(["-o", sequential_output])
            else:
                cmd.extend(["-o", test_output])
        else:
            cmd.extend(["-o", "output_tmp.txt"])

        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)

            found_time = False
            for line in result.stdout.split('\n'):
                if "Convolution time:" in line:
                    time_str = line.split(':')[1].strip().split()[0]
                    time_ms = int(time_str)
                    times.append(time_ms)
                    found_time = True
                    break

            if not found_time and run == 0:
                print(f"WARNING: No time found in Java output")

        except Exception as e:
            if run == 0:
                print(f"ERROR: {e}")
            continue

    if times and (threads is not None and threads > 0):
        verify_output(sequential_output, test_output, "Java")

    if times:
        return sum(times) / len(times)
    return None


def run_lab1_tests():
    cpp_results = []
    java_results = []

    print("LAB 1 - STANDARD CONVOLUTION TESTS")
    print()

    for config in LAB1_CONFIGS:
        n, m, k = config["n"], config["m"], config["k"]
        threads_list = config["threads"]
        size_key = f"{n}x{m}"

        print(f"Testing {size_key} (kernel {k}x{k})")

        input_file = generate_input(n, m, k)

        print("\n[C++ Tests]")

        print("Sequential", end='', flush=True)
        seq_time = run_cpp_test(input_file, "seq", strategy="horizontal")
        if seq_time:
            cpp_results.append({
                "size": size_key, "k": k,
                "mode": "sequential", "threads": "-", "strategy": "-",
                "time": seq_time, "speedup": 1.0
            })
            print(f"{seq_time:.2f} ms")

        for threads in threads_list:
            for strategy in LAB1_STRATEGIES:
                print(f"{threads}t {strategy[:4]}", end='', flush=True)
                time_ms = run_cpp_test(input_file, "par", threads, strategy)
                if time_ms and seq_time:
                    speedup = seq_time / time_ms
                    cpp_results.append({
                        "size": size_key, "k": k,
                        "mode": "parallel", "threads": threads, "strategy": strategy,
                        "time": time_ms, "speedup": speedup
                    })
                    print(f"{time_ms:.2f} ms (speedup: {speedup:.2f}x)")
                else:
                    print("FAILED")

        print("\n[Java Tests]")

        print("Sequential", end='', flush=True)
        seq_time = run_java_test(input_file, "seq", strategy="horizontal")
        if seq_time:
            java_results.append({
                "size": size_key, "k": k,
                "mode": "sequential", "threads": "-", "strategy": "-",
                "time": seq_time, "speedup": 1.0
            })
            print(f"{seq_time:.2f} ms")

        for threads in threads_list:
            for strategy in LAB1_STRATEGIES:
                print(f"{threads}t {strategy[:4]}", end='', flush=True)
                time_ms = run_java_test(input_file, "par", threads, strategy)
                if time_ms and seq_time:
                    speedup = seq_time / time_ms
                    java_results.append({
                        "size": size_key, "k": k,
                        "mode": "parallel", "threads": threads, "strategy": strategy,
                        "time": time_ms, "speedup": speedup
                    })
                    print(f"{time_ms:.2f} ms (speedup: {speedup:.2f}x)")
                else:
                    print("FAILED")

    return cpp_results, java_results


def run_lab2_tests():
    cpp_results = []
    java_results = []

    print("LAB 2 - IN-PLACE CONVOLUTION TESTS")
    print()

    for config in LAB2_CONFIGS:
        n, m, k = config["n"], config["m"], config["k"]
        threads_list = config["threads"]
        size_key = f"{n}x{m}"

        print(f"Testing {size_key} (kernel {k}x{k})")

        input_file = generate_input(n, m, k)

        print("\n[C++ In-Place Tests]")
        cpp_seq_time = None

        for threads in threads_list:
            mode = "seq" if threads == 0 else "par"
            label = "Sequential" if threads == 0 else f"{threads} threads"
            print(f"{label}", end='', flush=True)

            time_ms = run_cpp_test(input_file, mode, threads if threads > 0 else None, inplace=True)

            if time_ms:
                if threads == 0:
                    cpp_seq_time = time_ms
                    speedup = 1.0
                else:
                    speedup = cpp_seq_time / time_ms if cpp_seq_time else 0

                cpp_results.append({
                    "size": size_key, "k": k,
                    "mode": "sequential" if threads == 0 else "parallel",
                    "threads": "-" if threads == 0 else threads,
                    "strategy": "in-place",
                    "time": time_ms, "speedup": speedup
                })
                print(f"{time_ms:.2f} ms (speedup: {speedup:.2f}x)")
            else:
                print("FAILED")

        # Java tests
        print("\n[Java In-Place Tests]")
        java_seq_time = None

        for threads in threads_list:
            mode = "seq" if threads == 0 else "par"
            label = "Sequential" if threads == 0 else f"{threads} threads"
            print(f"{label}", end='', flush=True)

            time_ms = run_java_test(input_file, mode, threads if threads > 0 else None, inplace=True)

            if time_ms:
                if threads == 0:
                    java_seq_time = time_ms
                    speedup = 1.0
                else:
                    speedup = java_seq_time / time_ms if java_seq_time else 0

                java_results.append({
                    "size": size_key, "k": k,
                    "mode": "sequential" if threads == 0 else "parallel",
                    "threads": "-" if threads == 0 else threads,
                    "strategy": "in-place",
                    "time": time_ms, "speedup": speedup
                })
                print(f"{time_ms:.2f} ms (speedup: {speedup:.2f}x)")
            else:
                print("FAILED")

    return cpp_results, java_results


def generate_markdown_report(cpp_results, java_results, lab_num):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    title = "Standard Convolution" if lab_num == 1 else "In-Place Convolution"
    md = f"""# Lab {lab_num} - {title} Performance Results

**Generated:** {timestamp}
**Runs per test:** {NUM_RUNS}

## C++ Results

| Matrix Size | Kernel | Mode | Threads | Strategy | Time (ms) | Speedup |
|-------------|--------|------|---------|----------|-----------|---------|
"""

    prev = {"size": None, "k": None, "mode": None, "threads": None}

    for r in cpp_results:
        size_val = r["size"] if r["size"] != prev["size"] else ""
        k_val = f"{r['k']}x{r['k']}" if (r["size"] != prev["size"] or r["k"] != prev["k"]) else ""
        mode_val = r["mode"] if (r["size"] != prev["size"] or r["mode"] != prev["mode"]) else ""
        threads_val = str(r["threads"]) if (r["size"] != prev["size"] or r["mode"] != prev["mode"] or r["threads"] != prev["threads"]) else ""
        strategy_val = r["strategy"]

        md += f"| {size_val} | {k_val} | {mode_val} | {threads_val} | {strategy_val} | {r['time']:.2f} | {r['speedup']:.2f}x |\n"

        prev = {"size": r["size"], "k": r["k"], "mode": r["mode"], "threads": r["threads"]}

    md += "\n## Java Results\n\n"
    md += "| Matrix Size | Kernel | Mode | Threads | Strategy | Time (ms) | Speedup |\n"
    md += "|-------------|--------|------|---------|----------|-----------|----------|\n"

    prev = {"size": None, "k": None, "mode": None, "threads": None}

    for r in java_results:
        size_val = r["size"] if r["size"] != prev["size"] else ""
        k_val = f"{r['k']}x{r['k']}" if (r["size"] != prev["size"] or r["k"] != prev["k"]) else ""
        mode_val = r["mode"] if (r["size"] != prev["size"] or r["mode"] != prev["mode"]) else ""
        threads_val = str(r["threads"]) if (r["size"] != prev["size"] or r["mode"] != prev["mode"] or r["threads"] != prev["threads"]) else ""
        strategy_val = r["strategy"]

        md += f"| {size_val} | {k_val} | {mode_val} | {threads_val} | {strategy_val} | {r['time']:.2f} | {r['speedup']:.2f}x |\n"

        prev = {"size": r["size"], "k": r["k"], "mode": r["mode"], "threads": r["threads"]}

    return md


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 benchmark.py [1|2]")
        print("1 - Lab 1: Standard convolution")
        print("2 - Lab 2: In-place convolution")
        sys.exit(1)

    lab_num = int(sys.argv[1])

    if lab_num not in [1, 2]:
        print("Error: Lab number must be 1 or 2")
        sys.exit(1)

    if not compile_all():
        print("Compilation failed. Exiting.")
        return

    if lab_num == 1:
        cpp_results, java_results = run_lab1_tests()
        output_file = "results_lab1.md"
    else:
        cpp_results, java_results = run_lab2_tests()
        output_file = "results_lab2.md"

    md_content = generate_markdown_report(cpp_results, java_results, lab_num)

    with open(output_file, 'w') as f:
        f.write(md_content)

    print(f"Results saved to: {output_file}")

    for f in ["output_seq_cpp.txt", "output_test_cpp.txt",
              "output_seq_java.txt", "output_test_java.txt", "output_tmp.txt"]:
        if os.path.exists(f):
            os.remove(f)


if __name__ == "__main__":
    main()
