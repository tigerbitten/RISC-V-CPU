import uvm_pkg::*;
`include "uvm_macros.svh"

module alu_tb_top;
    alu_if vif();

    ALU dut (.a           (vif.a),
              .b           (vif.b),
              .alu_control (vif.alu_control),
              .result      (vif.result),
              .zero        (vif.zero),
              .negative    (vif.negative),
              .overflow    (vif.overflow),
              .carry       (vif.carry));

    initial begin
        uvm_config_db #(virtual alu_if)::set(null, "*", "vif", vif);
        run_test("alu_test");
    end
endmodule
