import subprocess
import os
from datetime import datetime

NUM_RUNS = 10
CPP_EXECUTABLE = "./cpp/build/convolution"
JAVA_BUILD_DIR = "./java/build"
JAVA_MAIN = "Convolution"
ODIN_EXECUTABLE = "./odin/build/convolution"

TEST_CONFIGS = [
    {"n": 10, "m": 10, "k": 3, "threads": [4]},
    {"n": 1000, "m": 1000, "k": 5, "threads": [1, 2, 4, 8, 16]},
    {"n": 10, "m": 10000, "k": 5, "threads": [2, 4, 8, 16]},
    {"n": 10000, "m": 10, "k": 5, "threads": [2, 4, 8, 16]},
    {"n": 10000, "m": 10000, "k": 5, "threads": [2, 4, 8, 16]},
]

STRATEGIES = ["horizontal", "vertical", "block"]

def run_cpp_test(input_file, memory_type, mode, threads=None, strategy="horizontal"):
    times = []
    
    for run in range(NUM_RUNS):
        cmd = [CPP_EXECUTABLE, "-i", input_file, "-m", memory_type, "-e", mode]
        
        if mode == "par":
            cmd.extend(["-t", str(threads), "-s", strategy])
        
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
                print(f"      WARNING: No time found in C++ output")
                
        except Exception as e:
            if run == 0:
                print(f"      ERROR: {e}")
            continue
    
    if times:
        return sum(times) / len(times)
    return None

def run_java_test(input_file, mode, threads=None, strategy="horizontal"):
    times = []

    for run in range(NUM_RUNS):
        cmd = ["java", "-cp", JAVA_BUILD_DIR, JAVA_MAIN, "-i", input_file, "-e", mode]

        if mode == "par":
            cmd.extend(["-t", str(threads), "-s", strategy])

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
                print(f"      WARNING: No time found in Java output")

        except Exception as e:
            if run == 0:
                print(f"      ERROR: {e}")
            continue

    if times:
        return sum(times) / len(times)
    return None

def run_odin_test(input_file, mode, threads=None, strategy="horizontal"):
    times = []

    for run in range(NUM_RUNS):
        cmd = [ODIN_EXECUTABLE, "-i", input_file, "-e", mode]

        if mode == "par":
            cmd.extend(["-t", str(threads), "-s", strategy])

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
                print(f"      WARNING: No time found in Odin output")

        except Exception as e:
            if run == 0:
                print(f"      ERROR: {e}")
            continue

    if times:
        return sum(times) / len(times)
    return None

def generate_input(n, m, k):
    filename = f"data/test_{n}x{m}_{k}.txt"
    os.makedirs("data", exist_ok=True)
    
    if not os.path.exists(filename):
        subprocess.run(["python3", "generate-input.py", str(n), str(m), str(k), filename], 
                      capture_output=True)
    return filename

def compile_cpp():
    print("Compiling C++...")
    if not os.path.exists(CPP_EXECUTABLE):
        result = subprocess.run(["make", "-C", "cpp"], capture_output=True, text=True)
        if result.returncode != 0:
            print("C++ compilation failed!")
            print(result.stderr)
            return False
        print("  ✓ C++ compiled successfully")
    else:
        print("  ✓ C++ executable exists")
    return True

def compile_java():
    print("Compiling Java...")
    result = subprocess.run(["make", "-C", "java"], capture_output=True, text=True)
    if result.returncode != 0:
        print("Java compilation failed!")
        print(result.stderr)
        return False
    print("  ✓ Java compiled successfully")
    return True

def compile_odin():
    print("Compiling Odin...")
    if not os.path.exists(ODIN_EXECUTABLE):
        result = subprocess.run(["make", "-C", "odin"], capture_output=True, text=True)
        if result.returncode != 0:
            print("Odin compilation failed!")
            print(result.stderr)
            return False
        print("  ✓ Odin compiled successfully")
    else:
        print("  ✓ Odin executable exists")
    return True

def compile_all():
    cpp_ok = compile_cpp()
    java_ok = compile_java()
    odin_ok = compile_odin()
    print()
    return cpp_ok and java_ok and odin_ok

def run_cpp_tests():
    results = []
    
    print("=== Running C++ Tests ===\n")
    
    for config in TEST_CONFIGS:
        n, m, k = config["n"], config["m"], config["k"]
        threads_list = config["threads"]
        size_key = f"{n}x{m}"
        
        print(f"C++: Testing {size_key} (kernel {k}x{k})...")
        
        input_file = generate_input(n, m, k)
        
        for memory_type in ["static", "vector"]:
            print(f"  {memory_type}:")
            
            seq_time = run_cpp_test(input_file, memory_type, "seq")
            if seq_time:
                results.append({
                    "size": size_key,
                    "k": k,
                    "memory": memory_type,
                    "mode": "sequential",
                    "threads": "-",
                    "strategy": "-",
                    "time": seq_time,
                    "speedup": 1.0
                })
                print(f"    seq: {seq_time:.2f} ms")
            
            for threads in threads_list:
                for strategy in STRATEGIES:
                    time = run_cpp_test(input_file, memory_type, "par", threads, strategy)
                    if time and seq_time:
                        speedup = seq_time / time
                        results.append({
                            "size": size_key,
                            "k": k,
                            "memory": memory_type,
                            "mode": "parallel",
                            "threads": threads,
                            "strategy": strategy,
                            "time": time,
                            "speedup": speedup
                        })
                        print(f"    {threads}t {strategy[:4]}: {time:.2f} ms")
        
        print()
    
    return results

def run_java_tests():
    results = []

    print("=== Running Java Tests ===\n")

    for config in TEST_CONFIGS:
        n, m, k = config["n"], config["m"], config["k"]
        threads_list = config["threads"]
        size_key = f"{n}x{m}"

        print(f"Java: Testing {size_key} (kernel {k}x{k})...")

        input_file = generate_input(n, m, k)

        print(f"  Java:")

        seq_time = run_java_test(input_file, "seq")
        if seq_time:
            results.append({
                "size": size_key,
                "k": k,
                "mode": "sequential",
                "threads": "-",
                "strategy": "-",
                "time": seq_time,
                "speedup": 1.0
            })
            print(f"    seq: {seq_time:.2f} ms")

        for threads in threads_list:
            for strategy in STRATEGIES:
                time = run_java_test(input_file, "par", threads, strategy)
                if time and seq_time:
                    speedup = seq_time / time
                    results.append({
                        "size": size_key,
                        "k": k,
                        "mode": "parallel",
                        "threads": threads,
                        "strategy": strategy,
                        "time": time,
                        "speedup": speedup
                    })
                    print(f"    {threads}t {strategy[:4]}: {time:.2f} ms")

        print()

    return results

def run_odin_tests():
    results = []

    print("=== Running Odin Tests ===\n")

    for config in TEST_CONFIGS:
        n, m, k = config["n"], config["m"], config["k"]
        threads_list = config["threads"]
        size_key = f"{n}x{m}"

        print(f"Odin: Testing {size_key} (kernel {k}x{k})...")

        input_file = generate_input(n, m, k)

        print(f"  Odin:")

        seq_time = run_odin_test(input_file, "seq")
        if seq_time:
            results.append({
                "size": size_key,
                "k": k,
                "mode": "sequential",
                "threads": "-",
                "strategy": "-",
                "time": seq_time,
                "speedup": 1.0
            })
            print(f"    seq: {seq_time:.2f} ms")

        for threads in threads_list:
            for strategy in STRATEGIES:
                time = run_odin_test(input_file, "par", threads, strategy)
                if time and seq_time:
                    speedup = seq_time / time
                    results.append({
                        "size": size_key,
                        "k": k,
                        "mode": "parallel",
                        "threads": threads,
                        "strategy": strategy,
                        "time": time,
                        "speedup": speedup
                    })
                    print(f"    {threads}t {strategy[:4]}: {time:.2f} ms")

        print()

    return results

def generate_markdown_report(cpp_results, java_results, odin_results):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    md = f"""# Convolution Performance Results

**Generated:** {timestamp}
**Runs per test:** {NUM_RUNS}

## C++ Results

| Matrix Size | Kernel | Memory Type | Mode | Threads | Strategy | Time (ms) | Speedup |
|-------------|--------|-------------|------|---------|----------|-----------|---------|
"""
    
    prev = {"size": None, "k": None, "memory": None, "mode": None, "threads": None, "strategy": None}
    
    for r in cpp_results:
        size_val = r["size"] if r["size"] != prev["size"] else ""
        k_val = f"{r['k']}x{r['k']}" if (r["size"] != prev["size"] or r["k"] != prev["k"]) else ""
        mem_val = r["memory"] if (r["size"] != prev["size"] or r["memory"] != prev["memory"]) else ""
        mode_val = r["mode"] if (r["size"] != prev["size"] or r["memory"] != prev["memory"] or r["mode"] != prev["mode"]) else ""
        threads_val = str(r["threads"]) if (r["size"] != prev["size"] or r["memory"] != prev["memory"] or r["mode"] != prev["mode"] or r["threads"] != prev["threads"]) else ""
        strategy_val = r["strategy"]
        
        md += f"| {size_val} | {k_val} | {mem_val} | {mode_val} | {threads_val} | {strategy_val} | {r['time']:.2f} | {r['speedup']:.2f}x |\n"
        
        prev["size"] = r["size"]
        prev["k"] = r["k"]
        prev["memory"] = r["memory"]
        prev["mode"] = r["mode"]
        prev["threads"] = r["threads"]
        prev["strategy"] = r["strategy"]
    
    md += f"\n## Java Results\n\n"
    md += "| Matrix Size | Kernel | Mode | Threads | Strategy | Time (ms) | Speedup |\n"
    md += "|-------------|--------|------|---------|----------|-----------|----------|\n"

    prev = {"size": None, "k": None, "mode": None, "threads": None, "strategy": None}

    for r in java_results:
        size_val = r["size"] if r["size"] != prev["size"] else ""
        k_val = f"{r['k']}x{r['k']}" if (r["size"] != prev["size"] or r["k"] != prev["k"]) else ""
        mode_val = r["mode"] if (r["size"] != prev["size"] or r["mode"] != prev["mode"]) else ""
        threads_val = str(r["threads"]) if (r["size"] != prev["size"] or r["mode"] != prev["mode"] or r["threads"] != prev["threads"]) else ""
        strategy_val = r["strategy"]

        md += f"| {size_val} | {k_val} | {mode_val} | {threads_val} | {strategy_val} | {r['time']:.2f} | {r['speedup']:.2f}x |\n"

        prev["size"] = r["size"]
        prev["k"] = r["k"]
        prev["mode"] = r["mode"]
        prev["threads"] = r["threads"]
        prev["strategy"] = r["strategy"]

    md += f"\n## Odin Results\n\n"
    md += "| Matrix Size | Kernel | Mode | Threads | Strategy | Time (ms) | Speedup |\n"
    md += "|-------------|--------|------|---------|----------|-----------|----------|\n"

    prev = {"size": None, "k": None, "mode": None, "threads": None, "strategy": None}

    for r in odin_results:
        size_val = r["size"] if r["size"] != prev["size"] else ""
        k_val = f"{r['k']}x{r['k']}" if (r["size"] != prev["size"] or r["k"] != prev["k"]) else ""
        mode_val = r["mode"] if (r["size"] != prev["size"] or r["mode"] != prev["mode"]) else ""
        threads_val = str(r["threads"]) if (r["size"] != prev["size"] or r["mode"] != prev["mode"] or r["threads"] != prev["threads"]) else ""
        strategy_val = r["strategy"]

        md += f"| {size_val} | {k_val} | {mode_val} | {threads_val} | {strategy_val} | {r['time']:.2f} | {r['speedup']:.2f}x |\n"

        prev["size"] = r["size"]
        prev["k"] = r["k"]
        prev["mode"] = r["mode"]
        prev["threads"] = r["threads"]
        prev["strategy"] = r["strategy"]

    return md

def main():
    if not compile_all():
        print("Compilation failed. Exiting.")
        return

    print("="*70)
    print("Complete Benchmark: C++, Java, and Odin")
    print("="*70)
    print(f"Runs per test: {NUM_RUNS}")
    print("="*70)
    print()

    cpp_results = run_cpp_tests()
    java_results = run_java_tests()
    odin_results = run_odin_tests()

    md_content = generate_markdown_report(cpp_results, java_results, odin_results)

    output_file = "results.md"
    with open(output_file, 'w') as f:
        f.write(md_content)

    print("="*70)
    print(f"Results saved to: {output_file}")
    print("="*70)

if __name__ == "__main__":
    main()
