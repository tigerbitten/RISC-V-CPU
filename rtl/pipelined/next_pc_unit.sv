import riscv_pkg::*;

module next_pc_unit(input branch_funct3_t funct3,
                    input jump_t          jump,
                    input                 ex_predicted_redirect,
                    input                 ex_branch_ctrl,
                    input                 zero,
                    input                 negative,
                    input                 overflow,
                    input                 carry,
                    input [31:0]          alu_result,
                    input [31:0]          imm,
                    input [31:0]          pc_plus_4,
                    input [31:0]          ex_pc_plus_4,
                    input [31:0]          pc_out,
                    output reg            redirect,
                    output reg            branch_taken,
                    output reg [31:0]     pc_plus_imm,
                    output reg [31:0]     next_pc);
    
    wire [31:0] adder_out = pc_out + imm;

    always_comb begin
        pc_plus_imm  = adder_out;
        branch_taken = 1'b0;

        if (ex_branch_ctrl) begin
            case (funct3)
              FUNCT3_BEQ  : branch_taken = zero;
              FUNCT3_BNE  : branch_taken = !zero;
              FUNCT3_BLT  : branch_taken = (negative ^ overflow);
              FUNCT3_BGE  : branch_taken = !(negative ^ overflow);
              FUNCT3_BLTU : branch_taken = !carry; //a < b unsigned
              FUNCT3_BGEU : branch_taken = carry;  //a >= b unsigned
              default     : branch_taken = 1'b0;
            endcase
        end

        //compute the target
        if (jump == JUMP_JALR)               //LSB of JALR target must be 0 per ISA
            next_pc = {alu_result[31:1], 1'b0};
        else if (jump == JUMP_JAL)
            next_pc = adder_out;
        else if (ex_branch_ctrl && branch_taken && !ex_predicted_redirect)
            next_pc = adder_out;
        else
            next_pc = pc_plus_4;

        //redirect reflects whether control flow actually diverts,
        //NOT a comparison against the (unrelated) live pc_plus_4
        //redirect only high if the prediction is WRONG for branches
        redirect = (jump != JUMP_NONE) || (ex_branch_ctrl && branch_taken && !ex_predicted_redirect);

        //this logic CORRECTLY overides the above
        //if we make a misprediction, assert redirect to flush
        //next_pc becomes ex_pc_plus_4 to fix the mispredicted next_pc
        if (ex_branch_ctrl && ex_predicted_redirect && !branch_taken) begin
            next_pc  = ex_pc_plus_4;
            redirect = 1'b1;
        end
        
    end
endmodule
