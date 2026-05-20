`timescale 1ns/1ps
module data_memory_tb;
    reg clk, mem_read, mem_write;
    reg [31:0] write_data, address, read_data;
    reg [2:0] funct3;

    data_memory DUT (.clk        (clk),
                     .mem_read   (mem_read),
                     .mem_write  (mem_write),
                     .write_data (write_data),
                     .address    (address),
                     .funct3     (funct3),
                     .read_data  (read_data));
    
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

    task write (input [31:0] test_address,
                input [31:0] test_write_data,
                input [2:0]  test_funct3);
        begin
            write_data = test_write_data;
            address    = test_address;
            funct3     = test_funct3;
        end
    endtask

    task check (input [31:0] test_address,
                input [31:0] expected,
                input [2:0]  test_funct3);
        begin
            address = test_address;
            funct3  = test_funct3;
            
            #1;

            if (read_data !== expected) begin
                $display("FAIL: address=%h data=%h expected=%h", address, read_data, expected);
            end else begin
                $display("PASS: address=%h data=%h", address, read_data);
            end
        end
    endtask

    initial begin
        tick();
        tick();

        //test SB and LB and LBU
        mem_write = 1;
        write(32'd0, 32'hDCCD_DDDD, 3'b000); //SB
        tick();
        mem_write = 0;
        tick();
        mem_read = 1;
        tick();
        check(32'd0, 32'hFFFF_FFDD, 3'b000); //LB
        check(32'd0, 32'h0000_00DD, 3'b100); //LBU
        mem_read = 0;

        //test SH and LH and LHU
        mem_write = 1;
        write(32'h0000_0002, 32'hCCCC_EEEE, 3'b001); //SH
        tick();
        mem_read = 1;
        mem_write = 0;
        check(32'h0000_0002, 32'hFFFF_EEEE, 3'b001); //LH
        check(32'h0000_0002, 32'h0000_EEEE, 3'b101); //LHU        
        check(32'd0, 32'hFFFF_FFDD, 3'b000);         //LB at index 0
        mem_read = 0;

        //test SW and LW
        mem_write = 1;
        write(32'h0000_0006, 32'hFFFF_FFFF, 3'b010); //SW
        tick();
        mem_read = 1;
        mem_write = 0;
        check(32'h0000_0006, 32'hFFFF_FFFF, 3'b010); //LW
        check(32'h0000_0002, 32'hFFFF_EEEE, 3'b001); //LH from before

        //read and write at same time
        mem_write = 1;
        mem_read  = 1;
        write(32'h0000_0006, 32'hAAAA_AAAA, 3'b010); //SW
        check(32'h0000_0006, 32'hFFFF_FFFF, 3'b010); //LW -- change should not have taken effect yet
        tick(); //wait one clock
        check(32'h0000_0006, 32'hAAAA_AAAA, 3'b010); //LW -- change should be visible
    end
endmodule
