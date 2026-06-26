module rgb_pwm(input        khz_clk,
               input [23:0] full_rgb,
               output reg   red,
               output reg   green,
               output reg   blue);
    
    reg [7:0] count;

    always_ff @(posedge khz_clk) begin
        count     <= count + 1;
        
        if (count < full_rgb[23:16])
            red   <= 1;
        else
            red   <= 0;
        if (count < full_rgb[15:8])
            green <= 1;
        else
            green <= 0;
        if (count < full_rgb[7:0])
            blue  <= 1;
        else
            blue  <= 0;
    end
    
endmodule
