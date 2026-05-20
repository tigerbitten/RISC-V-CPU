module data_memory(input             clk,
                   input             mem_read,
                   input             mem_write,
                   input [31:0]      write_data,
                   input [31:0]      address,
                   input [2:0]       funct3,
                   output reg [31:0] read_data);
    
    reg [7:0] memory [0:1023];
    
    always_ff @(posedge clk) begin
        if (mem_write) begin
            case (funct3)
              3'b010 : begin //SW
                  memory[address]   <= write_data[7:0];
                  memory[address+1] <= write_data[15:8];
                  memory[address+2] <= write_data[23:16];
                  memory[address+3] <= write_data[31:24];
              end
              3'b001 : begin //SH
                  memory[address]   <= write_data[7:0];
                  memory[address+1] <= write_data[15:8];
              end
              3'b000 : begin //SB
                  memory[address]   <= write_data[7:0];
              end
            endcase
        end
    end

    always_comb begin
        if (mem_read) begin
            case (funct3)
              3'b010 : read_data = {memory[address+3], memory[address+2], memory[address+1], memory[address]};
              3'b001 : read_data = {{16{memory[address+1][7]}}, memory[address+1], memory[address]};
              3'b101 : read_data = {{16{1'b0}}, memory[address+1], memory[address]};
              3'b000 : read_data = {{24{memory[address][7]}}, memory[address]};
              3'b100 : read_data = {{24{1'b0}}, memory[address]};
            endcase
        end else begin
            read_data = 0;
        end
    end
endmodule
