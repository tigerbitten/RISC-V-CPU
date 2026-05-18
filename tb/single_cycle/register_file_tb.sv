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
            rd_addr = test_rd_addr;
            rd_data = test_rd_data;
        end
    endtask

    task check (input [4:0]  test_read_1,
                input [4:0]  test_read_2,
                input [31:0] expected_1,
                input [31:0] expected_2);
        begin
            rs1_addr = test_read_1;
            rs2_addr = test_read_2;
            
            #1;
            
            if (rs1_data !== expected_1 || rs2_data !== expected_2) begin
                $display("FAIL: rs1_addr=%b rs2_addr=%b rs1_data=%h rs2_data=%h expected_1=%h expected_2=%h", rs1_addr, rs2_addr, rs1_data, rs2_data, expected_1, expected_2);
            end else begin
                $display("PASS: rs1_addr=%b rs2_addr=%b rs1_data=%b rs2_data=%b", rs1_addr, rs2_addr, rs1_data, rs2_data);
            end
        end
    endtask

    initial begin
        reg_write = 0;
        reset = 1;
        repeat(5) tick();
        reset = 0;
        check(5'b00000, 5'b10010, 32'd0, 32'd0); //all should be 0 after reset
        
        reg_write = 1;
        write(32'hFFFF_FFFF, 5'b10000); //test write
        tick();
        write(32'hFFFF_FFFF, 5'b00000); //attempt to overwrite 0 address
        tick();
        
        reg_write = 0;
        check(5'b10000, 5'b00000, 32'hFFFF_FFFF, 32'h0000_0000); //make sure 0 didnt get overwritten
        tick();
        
        reg_write = 1;
        write(32'hFFFF_FFFF, 5'b00001);
        check(5'b00001, 5'b10000, 32'h0000_0000, 32'hFFFF_FFFF); //most recent write shouldnt take effect
        tick();
        
        reg_write = 0;
        check(5'b00001, 5'b10000, 32'hFFFF_FFFF, 32'hFFFF_FFFF); //now the most recent write should show
        tick();

        reg_write = 0; //ensure writes only take place when reg_write is enabled
        write(32'hFFFF_FFFF, 5'b01010);
        tick();
        check(5'b01010, 5'b00000, 32'd0, 32'd0); //most recent write should not go through
    end
endmodule
