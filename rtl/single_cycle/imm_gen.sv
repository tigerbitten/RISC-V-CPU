import riscv_pkg::*;

module imm_gen(input      [31:0] instruction,
               output reg [31:0] imm);

    always_comb begin
        case (instruction[6:0]) //decode type from opcode
          OP_ALU_IMM, OP_LOAD, OP_JALR : imm = {{20{instruction[31]}}, instruction[31:20]};
          OP_STORE                     : imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
          OP_LUI, OP_AUIPC             : imm = {instruction[31:12], 12'b000000000000};

          OP_BRANCH : imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
          
          OP_JAL    : imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:25], instruction[24:21], 1'b0};
          
          default   : imm = 32'd0;
        endcase
    end
endmodule
