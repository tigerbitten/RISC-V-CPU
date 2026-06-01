import riscv_pkg::*;

module cpu_top_tb;

    reg clk, reset;
    
    cpu_top dut (.clk   (clk),
                 .reset (reset));

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

    task check_reg(input [4:0] register_num,
                   input [31:0] expected_val);
        begin
            if (dut.reg_file.registers[register_num] !== expected_val)
                $display("FAIL: register=%d val=%h expected=%h", register_num, dut.reg_file.registers[register_num], expected_val);
            else
                $display("PASS: register=%d val=%h", register_num, expected_val);
        end
    endtask

    task check_mem (input [31:0] addr,
                    input [31:0] expected_val,
                    input        mem_width_t width);
        begin
            reg [31:0] actual;
            
            case(width)
              MEM_WIDTH_BYTE     : actual = dut.data_mem.memory[addr];
              MEM_WIDTH_HALFWORD : actual = {dut.data_mem.memory[addr+1], dut.data_mem.memory[addr]};
              MEM_WIDTH_WORD     : actual = {dut.data_mem.memory[addr+3], dut.data_mem.memory[addr+2], dut.data_mem.memory[addr+1], dut.data_mem.memory[addr]};
            endcase

            if (actual !== expected_val)
                $display("FAIL: actual=%h expected=%h width=%s", actual, expected_val, width.name());
            else
                $display("PASS: actual=%h expected=%h width=%s", actual, expected_val, width.name());
        end
    endtask

    initial begin
        reset = 1;
        tick();
        reset = 0;
        
//---CHECKS FOR program_test_1.mem---        
        //check load immediates section
        tick();
        tick();
        check_reg(1, 32'd5);
        check_reg(2, 32'd3);

        //check R-type arithmetic section
        for (int i = 0; i < 7; i++) begin
            tick();
        end
        check_reg(3, 32'd8);
        check_reg(4, 32'd2);
        check_reg(5, 32'd1);
        check_reg(6, 32'd7);
        check_reg(7, 32'd6);
        check_reg(1, 32'd5); //
        check_reg(2, 32'd3); //
        check_reg(8, 32'd1); //currently failing
        check_reg(9, 32'd1);
    end
    
endmodule
