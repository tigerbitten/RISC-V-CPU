module hex_display_4(input            khz_clk,
                     input [15:0]     switches,
                     output [7:0]     active_segments,
                     output reg [3:0] active_digit);

    reg [1:0] count; //count goes from 0 to 3
    reg [3:0] active_switches;
    hex_encode he (.bin(active_switches),
                   .hex(active_segments));

    always_ff @(posedge khz_clk) begin
        count <= count + 1;
    end

    always_comb begin //choose which switches/digit active based on current clock count
        case (count)
          0: begin
              active_switches = switches[15:12];
              active_digit = 4'b0111;
          end
          1: begin
              active_switches = switches[11:8];
              active_digit = 4'b1011;
          end
          2: begin
              active_switches = switches[7:4];
              active_digit = 4'b1101;
          end
          3: begin
              active_switches = switches[3:0];
              active_digit = 4'b1110;
          end
        endcase
    end
endmodule
