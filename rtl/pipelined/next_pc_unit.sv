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
    reg         branch_taken;

    always_comb begin
        pc_plus_imm  = adder_out;
        branch_taken = 1'b0;

        if (branch_ctrl) begin
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
        else if (branch_ctrl && branch_taken)
            next_pc = adder_out;
        else
            next_pc = pc_plus_4;

        //redirect reflects whether control flow actually diverts,
        //NOT a comparison against the (unrelated) live pc_plus_4
        redirect = (jump != JUMP_NONE) || (branch_ctrl && branch_taken);
    end
endmodule
