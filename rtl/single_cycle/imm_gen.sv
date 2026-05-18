module imm_gen(input      [31:0] instruction,
               output reg [31:0] imm);

    always_comb begin
        case (instruction[6:0]) //decode type from opcode
          7'b0010011, 7'b0000011, 7'b1100111 : imm = {{20{instruction[31]}}, instruction[31:20]}; //I-Type
          7'b0100011 : imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};      //S-Type
          7'b0110111, 7'b0010111 : imm = {instruction[31:12], 12'b000000000000};                  //U-Type

          7'b1100011 : imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0}; //B-Type
          7'b1101111 : imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:25], instruction[24:21], 1'b0}; //J-Type
          default    : imm = 32'd0;
        endcase
    end
endmodule
