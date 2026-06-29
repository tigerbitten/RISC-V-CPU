import riscv_pkg::*;

module program_count(input             clk,
                     input             reset,
                     input             stall,
                     input             redirect,
                     input [31:0]      next_pc,
                     output reg [31:0] pc_plus_4,
                     output reg [31:0] pc_out);

    assign pc_plus_4 = pc_out + 4;
    
    always_ff @(posedge clk) begin
        if (reset)
            pc_out <= 32'b0;
        else if (!stall || redirect)
            pc_out <= next_pc;
    end
endmodule
