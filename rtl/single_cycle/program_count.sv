import riscv_pkg::*;

module program_count(input                 clk,
                     input                 reset,
                     input branch_funct3_t funct3,
                     input [31:0]          pc_in,
                     input jump_t          jump,
                     input                 branch_ctrl,
                     input                 zero,
                     input                 negative,
                     input                 overflow,
                     input                 carry,
                     input [31:0]          alu_result,
                     output reg [31:0]     pc_plus_4,
                     output reg [31:0]     pc_out);
    
    reg [31:0] next_pc;

    always_ff @(posedge clk) begin
        if (reset)
            pc_out <= 32'b0;
        else
            pc_out <= next_pc;
    end

    always_comb begin
        next_pc   = pc_in + 4; //default
        pc_plus_4 = pc_in + 4; //for MUX for writeback to register
        
        if (jump == JUMP_JALR) begin //LSB of JALR target must be 0 according to ISA
            next_pc = {alu_result[31:1], 1'b0};
        end else if (jump == JUMP_JAL) begin
            next_pc = alu_result;
        end else if (branch_ctrl) begin
            case (funct3)
              FUNCT3_BEQ  : if (zero)                   next_pc = alu_result;
              FUNCT3_BNE  : if (!zero)                  next_pc = alu_result;
              FUNCT3_BLT  : if (negative ^ overflow)    next_pc = alu_result;
              FUNCT3_BGE  : if (!(negative ^ overflow)) next_pc = alu_result;
              FUNCT3_BLTU : if (carry)                  next_pc = alu_result;
              FUNCT3_BGEU : if (!carry)                 next_pc = alu_result;
            endcase
        end
    end
endmodule
