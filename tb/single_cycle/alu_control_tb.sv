module alu_control_tb;
    
    reg [1:0] alu_op;
    reg [2:0] funct3;
    reg       funct7_30; //only care about one bit 30 of funct7 for base instructions
    reg [3:0] alu_control;
    
    alu_control dut (.alu_op      (alu_op),
                     .funct3      (funct3),
                     .funct7_30   (funct7_30),
                     .alu_control (alu_control));

    task check_alu_control (input [1:0] test_alu_op,
                            input [2:0] test_funct3,
                            input       test_funct7_30,
                            input [3:0] expected_alu_control);
        begin
            alu_op = test_alu_op;
            funct3 = test_funct3;
            funct7_30 = test_funct7_30;
            
            #1;
            
            if (alu_control !== expected_alu_control) begin
                $display("FAIL: alu_op=%b funct3=%b funct7_30=%b alu_control=%b expected=%b", alu_op, funct3, funct7_30, alu_control, expected_alu_control);
            end else begin
                $display("PASS: alu_op=%b funct3=%b funct7_30=%b alu_control=%b", alu_op, funct3, funct7_30, alu_control);
            end
        end        
    endtask

    initial begin
        //ALUop = 00 means add regardless of funct fields
        check_alu_control(2'b00, 3'bxxx, 1'bx, 4'b0010);

        //ALUop = 01 means sub regardless of funct fields
        check_alu_control(2'b01, 3'bxxx, 1'bx, 4'b0110);
        
// R-Type/I-Type -------------------------------
        check_alu_control(2'b10, 3'b000, 1'b0, 4'b0010); //Add
        check_alu_control(2'b10, 3'b000, 1'b1, 4'b0110); //Sub
        check_alu_control(2'b10, 3'b111, 1'b0, 4'b0000); //And
        check_alu_control(2'b10, 3'b110, 1'b0, 4'b0001); //Or
        check_alu_control(2'b10, 3'b001, 1'b0, 4'b0100); //SLL
        check_alu_control(2'b10, 3'b010, 1'b0, 4'b0111); //SLT
        check_alu_control(2'b10, 3'b011, 1'b0, 4'b1000); //SLTU
        check_alu_control(2'b10, 3'b100, 1'b0, 4'b0011); //XOR
        check_alu_control(2'b10, 3'b101, 1'b0, 4'b0101); //SRL
        check_alu_control(2'b10, 3'b101, 1'b1, 4'b1001); //SRA

        // ALUop = 11;
        check_alu_control(2'b11, 3'bxxx, 1'bx, 4'b1010); //LUI
        $finish;
    end
endmodule
