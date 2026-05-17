module register_file(input         clk,
                     input         reset,
                     input         reg_write,
                     input [4:0]   rs1_addr,
                     input [4:0]   rs2_addr,
                     input [4:0]   rd_addr,
                     input [31:0]  rd_data,
                     output [31:0] rs1_data,
                     output [31:0] rs2_data);
    
    reg [31:0] registers [31:0];
    
    assign registers[0] = 0;
    assign rs1_data = registers[rs1_addr];
    assign rs2_data = registers[rs2_addr];
    
    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 1; i < 32; i++) begin
                registers[i] <= 32'b0;
            end
        end else begin
            if (reg_write) begin
                registers[rd_addr] <= rd_data;
            end
        end
    end
endmodule
                     
                     
