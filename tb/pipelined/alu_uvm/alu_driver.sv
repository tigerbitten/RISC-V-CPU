import riscv_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class alu_driver extends uvm_driver #(alu_seq_item);
    `uvm_component_utils(alu_driver)
    virtual alu_if vif;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual alu_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "vif not set for alu_driver");
    endfunction

    task run_phase(uvm_phase phase);
        alu_seq_item req;
        
        forever begin
            seq_item_port.get_next_item(req); 
            vif.a           = req.a; //drive req's fields onto vif
            vif.b           = req.b;
            vif.alu_control = req.alu_control;
            #1;
            seq_item_port.item_done();
        end
    endtask
endclass
