module instruction_memory_tb;

    reg [31:0] program_count, instruction;
    integer    pass_count = 0;
    integer    fail_count = 0;
    
    instruction_memory #(.MEM_FILE("instruction_mem_test_2048.mem")) DUT (.program_count (program_count),
                                                                          .instruction   (instruction));
    
    initial begin
        for (int i = 0; i < 2048; i++) begin
            program_count = i*4;
            
            #1;
            
            if (i !== instruction) begin
                $display("FAIL: expected=%d instruction=%d pc=%h", i, instruction, program_count);
                fail_count++;
            end else begin
                $display("PASS: expected=%d instruction=%d pc_d=%d, pc_h=%h", i, instruction, program_count, program_count);
                pass_count++;
            end
        end
        
        $display("PASSED: %0d / 2048", pass_count);
        $finish;
    end
    //instruction_mem_test.mem: each line counts upwards in hex from 0 to 255
    //instruction_mem_test_2048.mem: each line counts upwards in hex from 0 to 2047
    //this testbench assumes instruction_mem_test_2048.mem is the file begin loaded
endmodule
