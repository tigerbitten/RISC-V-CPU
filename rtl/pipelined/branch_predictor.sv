import riscv_pkg::*;

module branch_predictor(input             clk,
                        input             reset,
                        input             branch_ctrl,
                        input             ex_branch_ctrl,
                        input             branch_taken,
                        input [31:0]      id_pc_out,
                        input [31:0]      imm,
                        input [7:0]       ex_pht_index,
                        output reg [31:0] predicted_next_pc,
                        output reg [7:0]  pht_index,
                        output reg        predicted_redirect);

    reg [1:0] pht [255:0]; //pattern history table
    reg [7:0] ghr;         //global history register

    always_comb begin
        pht_index          = 8'b0; //defaults to be overridden
        predicted_redirect = 1'b0; //avoids inferring unwanted latches
        predicted_next_pc  = 32'b0;
        
        if (branch_ctrl) begin
            pht_index          = ghr ^ id_pc_out[9:2];
            predicted_redirect = pht[pht_index][1];
            predicted_next_pc  = imm + id_pc_out;
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            ghr <= 8'b0;
            for (int i = 0; i < 256; i++) begin
                pht[i] <= 2'b10; //reset PHT to 10 (weakly taken)
            end
        end else if (ex_branch_ctrl) begin
            if (pht[ex_pht_index] != 2'b11 && branch_taken) //actual taken
                pht[ex_pht_index] <= pht[ex_pht_index] + 1;
            else if (pht[ex_pht_index] != 2'b00 && (!branch_taken)) //actual not taken
                pht[ex_pht_index] <= pht[ex_pht_index] - 1;

            ghr <= {ghr[6:0], branch_taken}; //update GHR, LSB is most recent
        end
    end
endmodule
