module clock_div #(parameter TERMINAL_COUNT = 50) //TC counts to one flip; 2 flips make a cycle
    (input      clk,
     output reg clk_div);

    reg [$clog2(TERMINAL_COUNT)-1:0] count;

    always_ff @(posedge clk) begin
        if (count >= TERMINAL_COUNT-1) begin //must be TC - 1 because we start from 0
            count   <= 0;
            clk_div <= ~clk_div;
        end
        
        else begin
            count <= count + 1;
        end
    end
endmodule
