import uvm_pkg::*;
`include "uvm_macros.svh"

class alu_agent extends uvm_agent;
    `uvm_component_utils(alu_agent)

    alu_driver    driver;
    alu_sequencer sequencer;
    alu_monitor   monitor;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver    = alu_driver::type_id::create("driver", this);
        sequencer = alu_sequencer::type_id::create("sequencer", this);
        monitor   = alu_monitor::type_id::create("monitor", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
endclass
