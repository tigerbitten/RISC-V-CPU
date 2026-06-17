module detect_and_debounce(input  clk,
                           input  reset,
                           input  sig_in,
                           output sig_out);

    wire sig_rise, sig_fall;
    reg  state;
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 0;
        end else if (sig_rise) begin
            state <= 1;
        end else if (sig_fall) begin
            state <= 0;
        end
    end

    wire sig_released = (state && sig_fall);

    //we wait for the signal to have a posedge, and then a negedge, to start probation count
    //PROBATION COUNT STARTS ON RELEASE OF BUTTON
    //we can easily switch this between starting on press and release by removing the
    //second edge detect module, but ive found that on release works better for this
    edge_detect edge_detect_u0
        (.sig_rise (sig_rise),
         .reset    (reset),
         .clk      (clk),
         .sig_in   (sig_in));

    edge_detect edge_detect_u1
        (.sig_rise (sig_fall),
         .reset    (reset),
         .clk      (clk),
         .sig_in   (!sig_in));
    
    debounce debounce_u0
        (.sig_debounced  (sig_out),
         .reset          (reset),
         .clk            (clk),
         .sig_in         (sig_released));
endmodule

module edge_detect(input      clk, //detects a positive edge in sig_in
                   input      reset,
                   input      sig_in,
                   output reg sig_rise);
    
    reg sig_in_q;
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            sig_in_q <= 0;
        end else begin
            sig_in_q <= sig_in;
        end
    end

    always_comb begin
        sig_rise = sig_in && !sig_in_q;
    end
endmodule

module debounce(input  clk,
                input  reset,
                input  sig_in,
                output sig_debounced);
    
    reg [24:0] count;
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
        end else if (count >= 20_000_000) begin //using .2s of probation, it works better in practice
            count <= 0;
        end else if (count != 0 || sig_in) begin
            count <= count + 1;
        end
    end

    assign sig_debounced = (count == 0 && sig_in);
endmodule

