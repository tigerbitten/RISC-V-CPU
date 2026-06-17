module hex_encode(input [3:0]      bin,
                  output reg [7:0] hex);
    always_comb begin
        case (bin)
          0  : hex = 8'b11000000;
          1  : hex = 8'b11111001;
          2  : hex = 8'b10100100;
          3  : hex = 8'b10110000;
          4  : hex = 8'b10011001;
          5  : hex = 8'b10010010;
          6  : hex = 8'b10000010;
          7  : hex = 8'b11111000;
          8  : hex = 8'b10000000;
          9  : hex = 8'b10011000;
          10 : hex = 8'b10001000;
          11 : hex = 8'b10000011;
          12 : hex = 8'b11000110;
          13 : hex = 8'b10100001;
          14 : hex = 8'b10000110;
          15 : hex = 8'b10001110;
          default : hex = 8'b11111111;
        endcase
    end
endmodule
//encode binary number into 7 segment display input (hex form)
