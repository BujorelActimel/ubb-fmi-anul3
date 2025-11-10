import subprocess
import sys
import os
import statistics

class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    RESET = '\033[0m'

TEST_CONFIGS = [
    {
        'name': 'Varianta 1 - Test 1: N1=N2=16 digits',
        'input1': 'data/Numar1.txt',
        'input2': 'data/Numar2.txt',
        'variants': {
            'sequential': None,
            'mpi1': [5],
            'mpi1opt': [5],
        }
    },
    {
        'name': 'Varianta 1 - Test 2: N1=N2=10000 digits',
        'input1': 'data/N1_10000.txt',
        'input2': 'data/N2_10000.txt',
        'variants': {
            'sequential': None,
            'mpi1': [5, 9, 17],
            'mpi1opt': [5, 9, 17],
        }
    },
    {
        'name': 'Varianta 1 - Test 3: N1=100, N2=100000 (unequal)',
        'input1': 'data/N1_100.txt',
        'input2': 'data/N2_100000.txt',
        'variants': {
            'sequential': None,
            'mpi1': [5, 9, 17],
            'mpi1opt': [5, 9, 17],
        }
    },

    {
        'name': 'Varianta 2 - Test 1: N1=N2=16 digits',
        'input1': 'data/Numar1.txt',
        'input2': 'data/Numar2.txt',
        'variants': {
            'sequential': None,
            'mpi2': [4],
        }
    },
    {
        'name': 'Varianta 2 - Test 2: N1=N2=1000 digits',
        'input1': 'data/N1_1000.txt',
        'input2': 'data/N2_1000.txt',
        'variants': {
            'sequential': None,
            'mpi2': [4, 8, 16],
        }
    },
    {
        'name': 'Varianta 2 - Test 3: N1=100, N2=100000 (unequal)',
        'input1': 'data/N1_100.txt',
        'input2': 'data/N2_100000.txt',
        'variants': {
            'sequential': None,
            'mpi2': [4, 8, 16],
        }
    }
]

RUNS_PER_VARIANT = 10

def run_variant(variant, input1, input2, output, num_procs=None, runs=10):
    times = []

    variant_name = f"{variant}" if num_procs is None else f"{variant}-p{num_procs}"
    print(f"\n{Colors.BLUE}Running {variant_name} ({runs} times)...{Colors.RESET}")

    for i in range(1, runs + 1):
        try:
            if num_procs is None:
                cmd = ['./main', variant, input1, input2, output]
            else:
                cmd = ['mpirun', '-np', str(num_procs), '--oversubscribe', './main', variant, input1, input2, output]

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True
            )

            time_us = int(result.stdout.strip())
            times.append(time_us)

            print(f"  Run {i}/{runs}: {time_us / 1000:.3f} ms")

        except subprocess.CalledProcessError as e:
            print(f"{Colors.RED}Error running {variant_name}: {e.stderr}{Colors.RESET}")
            return None
        except ValueError as e:
            print(f"{Colors.RED}Error parsing output for {variant_name}: {result.stdout}{Colors.RESET}")
            return None

    return times

def validate_result(output_file, reference_file):
    if not os.path.exists(reference_file):
        print(f"{Colors.YELLOW}Warning: No reference file found{Colors.RESET}")
        return

    with open(output_file, 'r') as f1, open(reference_file, 'r') as f2:
        output = f1.read()
        reference = f2.read()

    if output == reference:
        print(f"{Colors.GREEN}Result CORRECT{Colors.RESET}")
    else:
        print(f"{Colors.RED}Result INCORRECT!{Colors.RESET}")
        print(f"\nExpected:\n{reference}")
        print(f"\nGot:\n{output}")
        raise ValueError(f"Validation failed for {output_file}")

def generate_reference(input1, input2, reference_file):
    print(f"\n{Colors.YELLOW}Generating reference result...{Colors.RESET}")

    try:
        subprocess.run(
            ['./main', 'sequential', input1, input2, reference_file],
            capture_output=True,
            check=True
        )
        print(f"{Colors.GREEN}Reference generated{Colors.RESET}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"{Colors.RED}Failed to generate reference: {e.stderr}{Colors.RESET}")
        return False

def format_time(time_us):
    if time_us >= 1000000:
        return f"{time_us / 1000000:.3f} s"
    elif time_us >= 1000:
        return f"{time_us / 1000:.3f} ms"
    else:
        return f"{time_us} μs"

def generate_markdown_report(all_results):
    md = "| Test Case | Variant | Processes | Avg Time |\n"
    md += "|-----------|---------|-----------|----------|\n"

    for test_result in all_results:
        test_name = test_result['name'].replace('Varianta 1 - ', '').replace('Varianta 2 - ', '')
        for result in test_result['results']:
            variant = result['variant']
            procs = result.get('processes', '-')
            avg = format_time(result['avg'])
            md += f"| {test_name} | {variant} | {procs} | {avg} |\n"

    return md

def main():
    print(f"{'='*70}")
    print(f"Big Number Addition - Automated Benchmark")
    print(f"{'='*70}")
    print(f"Runs per variant: {RUNS_PER_VARIANT}")
    print(f"Test configurations: {len(TEST_CONFIGS)}")
    print(f"{'='*70}\n")

    all_results = []

    for config in TEST_CONFIGS:
        print(f"\n{Colors.BLUE}{'='*70}{Colors.RESET}")
        print(f"{Colors.BLUE}{config['name']}{Colors.RESET}")
        print(f"{Colors.BLUE}{'='*70}{Colors.RESET}")

        input1 = config['input1']
        input2 = config['input2']

        reference_file = f"{input1.replace('.txt', '')}_reference.txt"
        if not os.path.exists(reference_file):
            if not generate_reference(input1, input2, reference_file):
                print(f"{Colors.RED}Skipping test due to reference generation failure{Colors.RESET}")
                continue

        results = []

        for variant, process_counts in config['variants'].items():
            if process_counts is None:
                output_file = f"data/Numar3_{variant}.txt"
                times = run_variant(variant, input1, input2, output_file, None, runs=1)

                if times is None:
                    continue

                validate_result(output_file, reference_file)

                results.append({
                    'variant': variant,
                    'runs': 1,
                    'avg': times[0]
                })
            else:
                for num_procs in process_counts:
                    output_file = f"data/Numar3_{variant}_p{num_procs}.txt"
                    times = run_variant(variant, input1, input2, output_file, num_procs, RUNS_PER_VARIANT)

                    if times is None:
                        continue

                    validate_result(output_file, reference_file)

                    results.append({
                        'variant': variant,
                        'processes': num_procs,
                        'runs': RUNS_PER_VARIANT,
                        'avg': int(statistics.mean(times))
                    })

        all_results.append({
            'name': config['name'],
            'input1': input1,
            'input2': input2,
            'results': results
        })

    print(f"\n{Colors.BLUE}{'='*70}{Colors.RESET}")
    print(f"{Colors.BLUE}Generating report...{Colors.RESET}")
    print(f"{Colors.BLUE}{'='*70}{Colors.RESET}")

    markdown = generate_markdown_report(all_results)

    output_md = "benchmark_results.md"
    with open(output_md, 'w') as f:
        f.write(markdown)

    print(f"\n{Colors.GREEN}Results saved to {output_md}{Colors.RESET}\n")

if __name__ == "__main__":
    main()
