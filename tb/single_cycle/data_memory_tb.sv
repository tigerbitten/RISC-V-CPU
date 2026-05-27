`timescale 1ns/1ps
import riscv_pkg::*;

module data_memory_tb;
    reg clk, mem_read, mem_write;
    reg [31:0] write_data, address, read_data;
    mem_funct3_t funct3;

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
                input        mem_funct3_t test_funct3);
        begin
            write_data = test_write_data;
            address    = test_address;
            funct3     = test_funct3;
        end
    endtask

    task check (input [31:0] test_address,
                input [31:0] expected,
                input        mem_funct3_t test_funct3);
        begin
            address = test_address;
            funct3  = test_funct3;
            
            #1;

            if (read_data !== expected) begin
                $display("FAIL: address=%h data=%h expected=%h funct3=%s", address, read_data, expected, funct3.name());
            end else begin
                $display("PASS: address=%h data=%h funct3=%s", address, read_data, funct3.name());
            end
        end
    endtask

    initial begin
        tick();
        tick();

        //test SB and LB and LBU
        mem_write = 1;
        write(32'd0, 32'hDCCD_DDDD, FUNCT3_BYTE); //SB
        tick();
        mem_write = 0;
        tick();
        mem_read = 1;
        tick();
        check(32'd0, 32'hFFFF_FFDD, FUNCT3_BYTE); //LB
        check(32'd0, 32'h0000_00DD, FUNCT3_BYTE_U); //LBU
        mem_read = 0;

        //test SH and LH and LHU
        mem_write = 1;
        write(32'h0000_0002, 32'hCCCC_EEEE, FUNCT3_HALFWORD); //SH
        tick();
        mem_read = 1;
        mem_write = 0;
        check(32'h0000_0002, 32'hFFFF_EEEE, FUNCT3_HALFWORD); //LH
        check(32'h0000_0002, 32'h0000_EEEE, FUNCT3_HALFWORD_U); //LHU        
        check(32'd0, 32'hFFFF_FFDD, FUNCT3_BYTE);         //LB at index 0
        mem_read = 0;

        //test SW and LW
        mem_write = 1;
        write(32'h0000_0006, 32'hFFFF_FFFF, FUNCT3_WORD); //SW
        tick();
        mem_read = 1;
        mem_write = 0;
        check(32'h0000_0006, 32'hFFFF_FFFF, FUNCT3_WORD); //LW
        check(32'h0000_0002, 32'hFFFF_EEEE, FUNCT3_HALFWORD); //LH from before

        //read and write at same time
        mem_write = 1;
        mem_read  = 1;
        write(32'h0000_0006, 32'hAAAA_AAAA, FUNCT3_WORD); //SW
        check(32'h0000_0006, 32'hFFFF_FFFF, FUNCT3_WORD); //LW -- change should not have taken effect yet
        tick(); //wait one clock
        check(32'h0000_0006, 32'hAAAA_AAAA, FUNCT3_WORD); //LW -- change should be visible
    end
endmodule
