module alu_control(input [1:0]      alu_op,
                   input [2:0]      funct3,
                   input            funct7_30,
                   output reg [3:0] alu_control);
    
    always_comb begin
        case (alu_op)
          2'b00 : alu_control = 4'b0010; //wire to add for stores, loads, jal(r), auipc 
          2'b01 : alu_control = 4'b0110; //wire to subtract
          2'b10 : case ({funct3, funct7_30})
                    4'b0000 : alu_control = 4'b0010; //ADD
                    4'b0001 : alu_control = 4'b0110; //SUB
                    4'b1110 : alu_control = 4'b0000; //AND
                    4'b1100 : alu_control = 4'b0001; //OR
                    4'b0010 : alu_control = 4'b0100; //SLL
                    4'b0100 : alu_control = 4'b0111; //SLT
                    4'b0110 : alu_control = 4'b1000; //SLTU
                    4'b1000 : alu_control = 4'b0011; //XOR
                    4'b1010 : alu_control = 4'b0101; //SRL
                    4'b1011 : alu_control = 4'b1001; //SRA
                  endcase
          2'b11 : alu_control = 4'b1010; //LUI passthrough
        endcase
    end
endmodule
