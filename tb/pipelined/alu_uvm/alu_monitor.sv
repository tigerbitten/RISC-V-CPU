import riscv_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class alu_monitor extends uvm_monitor;
    `uvm_component_utils(alu_monitor)
    virtual alu_if vif;

    uvm_analysis_port #(alu_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual alu_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "vif not set for alu_monitor")

        ap = new("ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        alu_seq_item item;

        forever begin
            @(vif.a, vif.b, vif.alu_control);
            #1;
            item = alu_seq_item::type_id::create("item");
            item.a           = vif.a;
            item.b           = vif.b;
            item.alu_control = vif.alu_control;
            item.result      = vif.result;
            item.zero        = vif.zero;
            item.negative    = vif.negative;
            item.overflow    = vif.overflow;
            item.carry       = vif.carry;
            ap.write(item);
        end
    endtask
endclass
