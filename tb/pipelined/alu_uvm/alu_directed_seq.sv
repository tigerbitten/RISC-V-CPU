import riscv_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class alu_directed_seq extends uvm_sequence #(alu_seq_item);
    `uvm_object_utils(alu_directed_seq)

    function new(string name = "alu_directed_seq");
        super.new(name);
    endfunction

    task body();
        alu_seq_item req;
        alu_control_t op;
        
        op = op.first();
        forever begin
            req = alu_seq_item::type_id::create("req");
            start_item(req);
            req.randomize();
            req.alu_control = op; //overwrite randomized alu_control field
            finish_item(req);
            
            if (op == op.last()) break;
            op = op.next();
        end
    endtask
endclass
