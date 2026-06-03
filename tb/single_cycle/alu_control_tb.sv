import riscv_pkg::*;

module alu_control_tb;
    
    alu_op_t alu_op;
    reg [2:0] funct3;
    reg       funct7_30; //only care about one bit 30 of funct7 for base instructions
    alu_control_t alu_control;
    
    alu_control dut (.alu_op      (alu_op),
                     .funct3      (funct3),
                     .funct7_30   (funct7_30),
                     .alu_control (alu_control));

    task check_alu_control (input       alu_op_t test_alu_op,
                            input [2:0] test_funct3,
                            input       test_funct7_30,
                            input       alu_control_t expected_alu_control);
        begin
            alu_op = test_alu_op;
            funct3 = test_funct3;
            funct7_30 = test_funct7_30;
            
            #1;
            
            if (alu_control !== expected_alu_control) begin
                $display("FAIL: alu_op=%s funct3=%b funct7_30=%b alu_control=%s expected=%b",
                         alu_op.name(), funct3, funct7_30, alu_control.name(), expected_alu_control.name());
            end else begin
                $display("PASS: alu_op=%s funct3=%b funct7_30=%b alu_control=%s",
                         alu_op.name(), funct3, funct7_30, alu_control.name());
            end
        end        
    endtask

    initial begin
        //ALUop = 00 means add regardless of funct fields
        check_alu_control(ALUOP_ADD, 3'bxxx, 1'bx, ALU_ADD);

        //ALUop = 01 means sub regardless of funct fields
        check_alu_control(ALUOP_SUB, 3'bxxx, 1'bx, ALU_SUB);
        
// R-Type -------------------------------
        check_alu_control(ALUOP_RTYPE, 3'b000, 1'b0, ALU_ADD); //Add
        check_alu_control(ALUOP_RTYPE, 3'b000, 1'b1, ALU_SUB); //Sub
        check_alu_control(ALUOP_RTYPE, 3'b111, 1'b0, ALU_AND); //And
        check_alu_control(ALUOP_RTYPE, 3'b110, 1'b0, ALU_OR);  //Or
        check_alu_control(ALUOP_RTYPE, 3'b001, 1'b0, ALU_SLL); //SLL
        check_alu_control(ALUOP_RTYPE, 3'b010, 1'b0, ALU_SLT); //SLT
        check_alu_control(ALUOP_RTYPE, 3'b011, 1'b0, ALU_SLTU); //SLTU
        check_alu_control(ALUOP_RTYPE, 3'b100, 1'b0, ALU_XOR); //XOR
        check_alu_control(ALUOP_RTYPE, 3'b101, 1'b0, ALU_SRL); //SRL
        check_alu_control(ALUOP_RTYPE, 3'b101, 1'b1, ALU_SRA); //SRA

        
// I-Type -------------------------------
        check_alu_control(ALUOP_ITYPE, 3'b000, 1'b0, ALU_ADD); //Add
        check_alu_control(ALUOP_ITYPE, 3'b111, 1'b0, ALU_AND); //And
        check_alu_control(ALUOP_ITYPE, 3'b110, 1'b0, ALU_OR);  //Or
        check_alu_control(ALUOP_ITYPE, 3'b001, 1'b0, ALU_SLL); //SLL
        check_alu_control(ALUOP_ITYPE, 3'b010, 1'b0, ALU_SLT); //SLT
        check_alu_control(ALUOP_ITYPE, 3'b011, 1'b0, ALU_SLTU); //SLTU
        check_alu_control(ALUOP_ITYPE, 3'b100, 1'b0, ALU_XOR); //XOR
        check_alu_control(ALUOP_ITYPE, 3'b101, 1'b0, ALU_SRL); //SRL
        check_alu_control(ALUOP_ITYPE, 3'b101, 1'b1, ALU_SRA); //SRA
        
// LUI
        check_alu_control(ALUOP_LUI, 3'bxxx, 1'bx, ALU_LUI); //LUI
        $finish;
    end
endmodule
