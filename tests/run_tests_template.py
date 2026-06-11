import subprocess
import os

# Machine specific paths - update these for your environment.
TESTS_DIR = os.path.dirname(os.path.abspath(__file__))
SRC_DIR   = os.path.join(TESTS_DIR, "src")
MEM_DIR   = os.path.join(TESTS_DIR, "mem")
VIVADO = r"C:\path\to\vivado.bat"        # path to vivado.bat in your Vivado bin directory
PROJECT = r"C:\path\to\your_project.xpr" # path to your Vivado .xpr project file
SIM_LOG = r"C:\path\to\simulate.log"     # path to xsim simulate.log in your project sim directory

pass_count = 0
fail_count = 0

def wsl(cmd):
    result = subprocess.run(["wsl"] + cmd, capture_output=True, text=True)
    return result

def assemble(src_file, elf_file):
    return wsl([
        "riscv64-unknown-elf-gcc",
        "-march=rv32i_zicsr", "-mabi=ilp32",
        "-nostdlib", "-nostartfiles",
        "-Ttext=0x0",
        src_file, "-o", elf_file
    ])

def extract_binary(elf_file, bin_file):
    return wsl([
        "riscv64-unknown-elf-objcopy",
        "-O", "binary",
        elf_file, bin_file
    ])

def convert_to_mem(bin_file, mem_file):
    with open(bin_file, 'rb') as f:
        data = f.read()
        
    with open(mem_file, 'w') as f:
            for i in range(0, len(data), 4):
                word = data[i:i+4]
                val = int.from_bytes(word, 'little')
                f.write(f'{val:08x}\n')

def generate_tcl(mem_file):
    tcl = f"""
open_project {PROJECT.replace("\\", "/")}
set_property top riscv_test_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
set_property generic {{MEM_FILE={mem_file.replace("\\", "/")}}} [get_filesets sim_1]
launch_simulation
run all
close_sim
exit
"""
    tcl_path = os.path.join(TESTS_DIR, "run_sim.tcl")
    with open(tcl_path, "w") as f:
        f.write(tcl)
    return tcl_path

def run_simulation(tcl_path):
    result = subprocess.run(
        [VIVADO, "-mode", "batch", "-source", tcl_path, "-nolog", "-nojournal"],
        capture_output=True, text=True
    )
    return result

def parse_result():
    with open(SIM_LOG, "r") as f:
        lines = f.readlines()
    for line in lines:
        if "PASS:" in line: #must display the word PASS or FAIL for each specific test
            return True     #or else parse_result won't count it
        if "FAIL:" in line:
            return False
    return None

def run_test(src_file):
    global pass_count, fail_count

    name     = os.path.splitext(os.path.basename(src_file))[0]
    elf_file = os.path.join(TESTS_DIR, name + ".elf")
    bin_file = os.path.join(TESTS_DIR, name + ".bin")
    mem_file = os.path.join(MEM_DIR, name + ".mem")

    print(f"Running {name}...")

    assemble(src_file, elf_file)
    extract_binary(elf_file, bin_file)
    convert_to_mem(bin_file, mem_file)
    tcl_path = generate_tcl(mem_file)
    run_simulation(tcl_path)

    result = parse_result()
    if result is True:
        print(f"  PASS: {name}")
        pass_count += 1
    elif result is False:
        print(f"  FAIL: {name}")
        fail_count += 1
    else:
        print(f"  UNKNOWN: {name} - no PASS/FAIL found in log")
        fail_count += 1

# Main
os.makedirs(MEM_DIR, exist_ok=True)

for filename in os.listdir(SRC_DIR):
    if filename.endswith(".S"):
        run_test(os.path.join(SRC_DIR, filename))

print(f"\nRESULTS: {pass_count} passed, {fail_count} failed")
