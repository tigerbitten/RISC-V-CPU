module ALU(input [31:0]      a,
           input [31:0]      b,
           input [3:0]       alu_control,
           output reg [31:0] result,
           output            zero);

    assign zero = (result == 0);

    always_comb begin
        case (alu_control)
          0  : result = a & b;
          1  : result = a | b;
          2  : result = a + b;
          3  : result = a ^ b;
          4  : result = a << b;
          5  : result = a >> b;
          6  : result = a - b;
          7  : result = ($signed(a) < $signed(b)) ? 1 : 0;
          8  : result = (a < b) ? 1 : 0;
          9  : result = $signed(a) >>> b;
          10 : result = b << 12; //LUI -- 20 bits passed in b become upper 20 of result
          //note that b is the port used for LUI
        endcase
    end
endmodule
           
