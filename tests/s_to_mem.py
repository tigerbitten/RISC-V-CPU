import subprocess
import os
import sys

#riscv-gnu-toolchain commands only work in wsl terminal
#assisted by Claude
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
    name     = os.path.splitext(filename)[0]

    tests_dir = os.path.dirname(os.path.abspath(__file__))
    src_file  = os.path.join(tests_dir, "src", filename)
    elf_file  = os.path.join(tests_dir, name + ".elf")
    bin_file  = os.path.join(tests_dir, name + ".bin")
    mem_file  = os.path.join(tests_dir, "mem", name + ".mem")

    r = subprocess.run(["wsl", "riscv64-unknown-elf-gcc",        #create .elf file
                         "-march=rv32i_zicsr", "-mabi=ilp32",
                         "-nostdlib", "-nostartfiles",
                         "-Ttext=0x0",
                         to_wsl_path(src_file), "-o", to_wsl_path(elf_file)],
                        capture_output=True, text=True)
    
    if r.returncode != 0:
        print("ASSEMBLE ERROR:", r.stderr)
        sys.exit(1)

    r = subprocess.run(["wsl", "riscv64-unknown-elf-objcopy",    #create .bin file
                         "-O", "binary",
                         to_wsl_path(elf_file), to_wsl_path(bin_file)],
                        capture_output=True, text=True)
    
    if r.returncode != 0:
        print("OBJCOPY ERROR:", r.stderr)
        sys.exit(1)

    convert_to_mem(bin_file, mem_file)   #translate to .mem file for $readmemh
    print(f"Wrote {mem_file}")

    r = subprocess.run(["wsl", "riscv64-unknown-elf-objdump",       #create .lst disassembly
                         "-d", "-Mno-aliases,reg-names=numeric", to_wsl_path(elf_file)],
                        capture_output=True, text=True)

    reg_table = """\
# ABI register reference:
# zero=x0  ra=x1   sp=x2   gp=x3   tp=x4   t0=x5   t1=x6   t2=x7
# s0=x8    s1=x9   a0=x10  a1=x11  a2=x12  a3=x13  a4=x14  a5=x15
# a6=x16   a7=x17  s2=x18  s3=x19  s4=x20  s5=x21  s6=x22  s7=x23
# s8=x24   s9=x25  s10=x26 s11=x27 t3=x28  t4=x29  t5=x30  t6=x31

"""

    lst_file = os.path.join(tests_dir, "lst", name + ".lst")
    with open(lst_file, 'w') as f:
        f.write(reg_table)
        f.write(r.stdout)
    print(f"Wrote {lst_file}")

if __name__ == "__main__":
    main()
