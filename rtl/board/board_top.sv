module board_top(input        clk,
                 input [3:0]  btn,
                 input [15:0] sw,
                 output [7:0] D0_SEG,
                 output [3:0] D0_AN,
                 output [7:0] D1_SEG,
                 output [3:0] D1_AN,
                 output [2:0] RGB0,
                 output [2:0] RGB1);
    
    parameter MEM_FILE = "test_rgb.mem";
    wire      reset;

    assign reset = sw[0];
    
    cpu_top #(.MEM_FILE(MEM_FILE)) dut (.clk   (debounced_btns[0]), //btn 0 is cpu clock
                                        .reset (reset));
    
    wire[31:0] pc_display = dut.pc.pc_out;
    
    //Create khz clk for 7 seg display
    wire khz_clk;
    
    clock_div #(.TERMINAL_COUNT(50_000)) clk_div_u0 (.clk     (clk),
                                                     .clk_div (khz_clk));
    //Display PC to 7 seg displays
    hex_display_4 display_right (.khz_clk         (khz_clk),
                                 .switches        (pc_display[31:16]),
                                 .active_segments (D0_SEG),
                                 .active_digit    (D0_AN));

    hex_display_4 display_left (.khz_clk         (khz_clk),
                                 .switches        (pc_display[15:0]),
                                 .active_segments (D1_SEG),
                                 .active_digit    (D1_AN));

    //Synchronize and Debounce btns
    wire [3:0] sanitized_btns, debounced_btns;
    
    sync_n #(.WIDTH(4)) sync
        (.clk(clk),
         .in(btn),
         .out(sanitized_btns));
    
    generate //generate 4 debouncers, 1 for each button
        for (genvar ii = 0; ii < 4; ii++) begin : gen_detect_and_debounce
            detect_and_debounce detect_and_debounce_u0
                (.sig_out                       (debounced_btns[ii]),
                 .clk                           (clk),
                 .sig_in                        (sanitized_btns[ii]),
                 .reset                         (reset));
        end
    endgenerate
endmodule

module sync_n #(parameter WIDTH = 1)
    (input                  clk,
     input [WIDTH-1:0]      in,
     output reg [WIDTH-1:0] out);
    
    reg [WIDTH-1:0] suspect;

    always @(negedge clk) begin
        suspect <= in;
    end

    always @(posedge clk) begin
        out <= suspect;
    end
endmodule
