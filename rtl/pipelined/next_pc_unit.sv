import riscv_pkg::*;

module next_pc_unit(input branch_funct3_t funct3,
                    input jump_t          jump,
                    input                 branch_ctrl,
                    input                 zero,
                    input                 negative,
                    input                 overflow,
                    input                 carry,
                    input [31:0]          alu_result,
                    input [31:0]          imm,
                    input [31:0]          pc_plus_4,
                    input [31:0]          pc_out,
                    output reg            redirect,
                    output reg [31:0]     pc_plus_imm,
                    output reg [31:0]     next_pc);
    
    wire [31:0] adder_out = pc_out + imm;
    
    always_comb begin
        next_pc     = pc_plus_4; //default
        pc_plus_imm = adder_out;
        
        if (jump == JUMP_JALR) begin //LSB of JALR target must be 0 according to ISA
            next_pc = {alu_result[31:1], 1'b0};
        end else if (jump == JUMP_JAL) begin
            next_pc = adder_out;
        end else if (branch_ctrl) begin
            case (funct3)
              FUNCT3_BEQ  : if (zero)                   next_pc = adder_out;
              FUNCT3_BNE  : if (!zero)                  next_pc = adder_out;
              FUNCT3_BLT  : if (negative ^ overflow)    next_pc = adder_out;
              FUNCT3_BGE  : if (!(negative ^ overflow)) next_pc = adder_out;
              FUNCT3_BLTU : if (carry)                  next_pc = adder_out;
              FUNCT3_BGEU : if (!carry)                 next_pc = adder_out;
            endcase

        end
        redirect = (next_pc != pc_plus_4); //evaluated AFTER next_pc is computed
    end
endmodule
