import subprocess
import os
import sys

def to_wsl_path(windows_path):
    path = windows_path.replace("\\", "/")
    if path[1] == ":":
        path = "/mnt/" + path[0].lower() + path[2:]
    return path

def convert_to_mem(bin_file, mem_file):
    with open(bin_file, 'rb') as f:
        data = f.read()
    with open(mem_file, 'w') as f:
        for i in range(0, len(data), 4):
            word = data[i:i+4]
            val = int.from_bytes(word, 'little')
            f.write(f'{val:08x}\n')

def main():
    if len(sys.argv) != 2:
        print("Usage: python s_to_mem.py <filename.S>")
        sys.exit(1)

    filename = sys.argv[1]
    name = os.path.splitext(filename)[0]

    tests_dir = os.path.dirname(os.path.abspath(__file__))
    src_file = os.path.join(tests_dir, "src", filename)
    elf_file = os.path.join(tests_dir, name + ".elf")
    bin_file = os.path.join(tests_dir, name + ".bin")
    mem_file = os.path.join(tests_dir, "mem", name + ".mem")

    r = subprocess.run(["wsl", "riscv64-unknown-elf-gcc",
                         "-march=rv32i_zicsr", "-mabi=ilp32",
                         "-nostdlib", "-nostartfiles",
                         "-Ttext=0x0",
                         to_wsl_path(src_file), "-o", to_wsl_path(elf_file)],
                        capture_output=True, text=True)
    if r.returncode != 0:
        print("ASSEMBLE ERROR:", r.stderr)
        sys.exit(1)

    r = subprocess.run(["wsl", "riscv64-unknown-elf-objcopy",
                         "-O", "binary",
                         to_wsl_path(elf_file), to_wsl_path(bin_file)],
                        capture_output=True, text=True)
    if r.returncode != 0:
        print("OBJCOPY ERROR:", r.stderr)
        sys.exit(1)

    convert_to_mem(bin_file, mem_file)
    print(f"Wrote {mem_file}")

if __name__ == "__main__":
    main()
