# RISC-V CPU
 
A RV32I RISC-V processor implementation written in SystemVerilog. Work in progress.
 
## Status
 
Core datapath components implemented and verified:
 
- ALU
- ALU Controller
- Register File
- Immediate Generator
- Instruction Memory
- Data Memory
- Control Unit
  
Each module has a corresponding testbench for simulation-based verification.
 
## Planned
 
Full pipeline integration (fetch, decode, execute, memory, writeback). First goal is a complete single-cycle implementation.
