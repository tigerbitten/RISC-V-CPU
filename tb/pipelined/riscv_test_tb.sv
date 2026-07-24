module riscv_test_tb;
       
    parameter MEM_FILE    = "test_branch_prediction.mem"; //test selection
    parameter BRANCH_PRED = 1; //enable and disable branch prediction
    parameter CYCLES      = 2000;
    
    integer   pass_count  = 0;
    integer   fail_count  = 0;
    integer   cycle_count = 0;
    
    reg clk, reset;
    
    cpu_top #(.MEM_FILE(MEM_FILE), .BRANCH_PRED(BRANCH_PRED)) dut (.clk   (clk),
                                                                   .reset (reset));
    always begin
        clk = 0;
        #10;
        clk = 1;
        #10;
    end

    task tick();
        begin
            $display("PC:%d PC:%h instruction:%h", dut.pc.pc_out, dut.pc.pc_out, dut.imem.instruction);
            @(posedge clk) #1;
            cycle_count++;
        end
    endtask

    initial begin
        $dumpfile("../../../../../../../riscv_cpu/waves.vcd");
        $dumpvars(0, cpu_top);
    end

    initial begin
        clk   = 0;
        reset = 1;
        tick(); //reset is SYNCHRONOUS so it needs a posedge
        #10;
        reset = 0;

        while (cycle_count < CYCLES) begin
            tick();
            if (dut.imem.instruction == 32'h0000006f) begin
                repeat(5) tick(); // drain pipeline before checking registers
                break;
            end //stop when we reach "done" loop.
        end

        if (riscv_test_tb.dut.reg_file.registers[3] == 32'd1) begin
            $display("PASS: %s | registers[3] = %0d", MEM_FILE, riscv_test_tb.dut.reg_file.registers[3]);
            pass_count++;
        end else begin
            $display("FAIL: %s | registers[3] = %0d", MEM_FILE, riscv_test_tb.dut.reg_file.registers[3]);
            fail_count++;
        end
        
        $display("PASSED: %0d FAILED: %0d", pass_count, fail_count);
        $display("cycle count: %0d", cycle_count);
        $finish;
    end
endmodule
