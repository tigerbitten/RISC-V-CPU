import uvm_pkg::*;
`include "uvm_macros.svh"

class alu_test extends uvm_test;
    `uvm_component_utils(alu_test)

    alu_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = alu_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        alu_directed_seq seq;

        phase.raise_objection(this);
        seq = alu_directed_seq::type_id::create("seq");
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass
