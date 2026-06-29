import riscv_pkg::*;

module hazard_unit(input       ex_mem_read,
                   input [4:0] ex_rd_addr,
                   input [4:0] id_rs1_addr,
                   input [4:0] id_rs2_addr,
                   output reg  stall);

    always_comb begin
        if (ex_mem_read &&
            ((ex_rd_addr == id_rs1_addr) ||
             (ex_rd_addr == id_rs2_addr)))
            stall = 1'b1;
        else
            stall = 1'b0;
    end
endmodule
