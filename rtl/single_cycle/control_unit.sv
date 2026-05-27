import riscv_pkg::*;

module control_unit(input [6:0]      opcode,
                    output reg [1:0] alu_op,
                    output reg       alu_src_b, //on when second input comes from imm_gen
                    output reg       alu_src_a, //on when first input is PC
                    output reg       branch_ctrl,
                    output reg       jump,
                    output reg       mem_read,
                    output reg       mem_write,
                    output reg [1:0] mem_to_reg, //00-> write from ALU,01->  from mem, 10-> from pc+4
                    output reg       reg_write);

    always_comb begin
        case (opcode)
          OP_BRANCH : begin
              alu_op      = ALUOP_SUB;
              alu_src_b   = 1'b0;
              alu_src_a   = 1'b0;
              branch_ctrl = 1'b1;
              jump        = 1'b0;
              mem_read    = 1'b0;
              mem_write   = 1'b0;
              mem_to_reg  = 2'b00;
              reg_write   = 1'b0;
          end
          OP_RTYPE : begin
              alu_op      = ALUOP_RTYPE;
              alu_src_b   = 1'b0;
              alu_src_a   = 1'b0;
              branch_ctrl = 1'b0;
              jump        = 1'b0;
              mem_read    = 1'b0;
              mem_write   = 1'b0;
              mem_to_reg  = 2'b00;
              reg_write   = 1'b1;
          end
          OP_ALU_IMM : begin
              alu_op      = ALUOP_RTYPE;
              alu_src_b   = 1'b1;
              alu_src_a   = 1'b0;
              branch_ctrl = 1'b0;
              jump        = 1'b0;
              mem_read    = 1'b0;
              mem_write   = 1'b0;
              mem_to_reg  = 2'b00;
              reg_write   = 1'b1;
          end
          OP_LOAD : begin
              alu_op      = ALUOP_ADD;
              alu_src_b   = 1'b1;
              alu_src_a   = 1'b0;
              branch_ctrl = 1'b0;
              jump        = 1'b0;
              mem_read    = 1'b1;
              mem_write   = 1'b0;
              mem_to_reg  = 2'b01;
              reg_write   = 1'b1;
          end
          OP_JALR : begin
              alu_op      = ALUOP_ADD;
              alu_src_b   = 1'b1;
              alu_src_a   = 1'b0;
              branch_ctrl = 1'b0;
              jump        = 1'b1;
              mem_read    = 1'b0;
              mem_write   = 1'b0;
              mem_to_reg  = 2'b10;
              reg_write   = 1'b1;
          end
          OP_STORE : begin
              alu_op      = ALUOP_ADD;
              alu_src_b   = 1'b1;
              alu_src_a   = 1'b0;
              branch_ctrl = 1'b0;
              jump        = 1'b0;
              mem_read    = 1'b0;
              mem_write   = 1'b1;
              mem_to_reg  = 2'b00;
              reg_write   = 1'b0;
          end
          OP_JAL : begin
              alu_op      = ALUOP_ADD;
              alu_src_b   = 1'b1;
              alu_src_a   = 1'b1;
              branch_ctrl = 1'b0;
              jump        = 1'b1;
              mem_read    = 1'b0;
              mem_write   = 1'b0;
              mem_to_reg  = 2'b10;
              reg_write   = 1'b1;
          end
          OP_LUI : begin
              alu_op      = ALUOP_LUI;
              alu_src_b   = 1'b1;
              alu_src_a   = 1'b0;
              branch_ctrl = 1'b0;
              jump        = 1'b0;
              mem_read    = 1'b0;
              mem_write   = 1'b0;
              mem_to_reg  = 2'b00;
              reg_write   = 1'b1;
          end
          OP_AUIPC : begin
              alu_op      = ALUOP_ADD;
              alu_src_b   = 1'b1;
              alu_src_a   = 1'b1;
              branch_ctrl = 1'b0;
              jump        = 1'b0;
              mem_read    = 1'b0;
              mem_write   = 1'b0;
              mem_to_reg  = 2'b00;
              reg_write   = 1'b1;
          end
        endcase
    end
endmodule
