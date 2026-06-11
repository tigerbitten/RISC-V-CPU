# RISC-V CPU
 
A RV32I RISC-V processor implementation written in SystemVerilog. Work in progress.
 
## Status

Single-Cycle implementation complete, currently verifying in simulation.
Modules implemented with passing testbenches:
 
- ALU
- ALU Controller
- Register File
- Immediate Generator
- Instruction Memory
- Data Memory
- Control Unit
- Program Count
- CPU Top
  
Each module has a corresponding testbench for simulation-based verification.

CPU level tests are written as RV32I assembly '.S' files that are then assembled with the riscv-gnu-toolchain, turned into .mem files, and loaded into instruction memory using $readmemh. Each test program writes 1 to register x3 on pass or a nonzero error code on fail.

Currently verifying full RV32I instruction set in simulation with assembly programs (found in tests/mem).

Not yet synthesized to hardware.

## Architecture

![Datapath Diagram](docs/box_diagram_cpu.png)

Link to more interactive
[Miro Board](https://miro.com/app/board/uXjVHM7kwYA=/?share_link_id=328386992955)
 
## Planned
 
Full pipeline integration (fetch, decode, execute, memory, writeback). First goal is a complete single-cycle implementation.
