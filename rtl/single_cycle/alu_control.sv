import riscv_pkg::*;

module alu_control(input alu_op_t       alu_op,
                   input [2:0]          funct3,
                   input                funct7_30,
                   output alu_control_t alu_control);
    
    always_comb begin
        case (alu_op)
          ALUOP_ADD   : alu_control = ALU_ADD; //always add
          ALUOP_SUB   : alu_control = ALU_SUB; //always sub
          ALUOP_RTYPE : case ({funct3, funct7_30})
                    4'b0000 : alu_control = ALU_ADD;
                    4'b0001 : alu_control = ALU_SUB;
                    4'b1110 : alu_control = ALU_AND;
                    4'b1100 : alu_control = ALU_OR;
                    4'b0010 : alu_control = ALU_SLL;
                    4'b0100 : alu_control = ALU_SLT;
                    4'b0110 : alu_control = ALU_SLTU;
                    4'b1000 : alu_control = ALU_XOR;
                    4'b1010 : alu_control = ALU_SRL;
                    4'b1011 : alu_control = ALU_SRA;
                        endcase
          ALUOP_ITYPE : case(funct3) //I-Type arithmetic operations don't always have funct7
                          3'b000 : alu_control = ALU_ADD;
                          3'b010 : alu_control = ALU_SLT;
                          3'b011 : alu_control = ALU_SLTU;
                          3'b100 : alu_control = ALU_XOR;
                          3'b110 : alu_control = ALU_OR;
                          3'b111 : alu_control = ALU_AND;
                          3'b001 : alu_control = ALU_SLL;
                          3'b101 : alu_control = (funct7_30) ? ALU_SRA : ALU_SRL;
                        endcase
          ALUOP_LUI   : alu_control = ALU_LUI;
        endcase
    end
endmodule
