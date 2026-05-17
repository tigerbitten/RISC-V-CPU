`timescale 1ns/1ps
module register_file_tb;
    reg clk, reset, reg_write;
    reg [4:0] rs1_addr, rs2_addr, rd_addr;
    reg [31:0] rd_data, rs1_data, rs2_data;
    
    register_file DUT (.clk       (clk),
                       .reset     (reset),
                       .rs1_addr  (rs1_addr),
                       .rs2_addr  (rs2_addr),
                       .rd_addr   (rd_addr),
                       .rd_data   (rd_data),
                       .reg_write (reg_write), //write enable
                       .rs1_data  (rs1_data),
                       .rs2_data  (rs2_data));
                           
    always begin
        clk = 0;
        #10;
        clk = 1;
        #10;
    end
    
    task tick();
        begin
            @(posedge clk) #1;
        end
    endtask

    task write (input [31:0] test_rd_data,
                input [4:0]  test_rd_addr);
        begin
            rd_addr   = test_rd_addr;
            rd_data   = test_rd_data;
            reg_write = 1;
            tick();
            reg_write = 0;
        end
    endtask

    task read (input [4:0] test_rs1_addr,
               input [4:0] test_rs2_addr);
        begin
            rs1_addr = test_rs1_addr;
            rs2_addr = test_rs2_addr;
            tick();
        end
    endtask

    initial begin
        reset = 1;
        repeat(5) tick();
        reset = 0;
        write(32'hFFFF_FFFF, 5'b1000);
        repeat(5) tick();
        read(5'b1000, 0);
    end
endmodule
