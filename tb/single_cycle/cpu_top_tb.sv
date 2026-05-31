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

    initial begin
        reset = 1;
        #10;
        reset = 0;
        tick();
        check_reg(1, 32'd5);
    end
    
endmodule
