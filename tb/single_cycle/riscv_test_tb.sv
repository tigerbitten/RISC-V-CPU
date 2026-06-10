module riscv_test_tb;
       
    parameter MEM_FILE = "add.mem";
    parameter CYCLES = 10000;
    
    integer   pass_count = 0;
    integer   fail_count = 0;
    
    reg clk, reset;
    
    cpu_top #(.MEM_FILE(MEM_FILE)) dut (.clk   (clk),
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

    initial begin
        clk   = 0;
        reset = 1;
        #10;
        reset = 0;

        repeat(CYCLES) tick();

        if (riscv_test_tb.dut.reg_file.registers[3] == 32'd1) begin
            $display("PASS: %s", MEM_FILE);
            pass_count++;
        end else begin
            $display("FAIL: %s | TESTNUM = %0d", MEM_FILE, riscv_test_tb.dut.reg_file.registers[3]);
            fail_count++;
        end
        
        $display("PASSED: %0d FAILED: %0d", pass_count, fail_count);
        $finish;
    end

endmodule
