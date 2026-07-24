import riscv_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class alu_seq_item extends uvm_sequence_item;
    rand alu_control_t alu_control;
    rand bit [31:0] a, b;
    
    logic [31:0]    result;
    logic           zero, negative, carry, overflow;
    
    `uvm_object_utils(alu_seq_item)
    
    function new(string name = "alu_seq_item");
        super.new(name);
    endfunction
endclass

//inputs get randomized, output member filled in later by monitor
