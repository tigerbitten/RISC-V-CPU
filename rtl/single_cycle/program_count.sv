import riscv_pkg::*;

module program_count(input             clk,
                     input             reset,
                     input [2:0]       funct3,
                     input [31:0]      pc_in,
                     input             jump,
                     input             branch_ctrl,
                     input             zero,
                     input             negative,
                     input             overflow,
                     input             carry,
                     input [31:0]      alu_result,
                     output reg [31:0] pc_out);
    
    reg [31:0] next_pc;

    always_ff @(posedge clk) begin
        if (reset)
            pc_out <= 32'b0;
        else
            pc_out <= next_pc;
    end

    always_comb begin
        next_pc = pc_in + 4; //default
        
        if (jump) begin
            next_pc = alu_result;
        end
        else if (branch_ctrl) begin
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
