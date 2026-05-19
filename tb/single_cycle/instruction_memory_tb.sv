module instruction_memory_tb;

    reg [31:0] program_count, instruction;
    
    instruction_memory DUT (.program_count (program_count),
                            .instruction   (instruction));
    
    initial begin
        for (int i = 0; i < 256; i++) begin
            program_count = i*4;
            
            #1;
            
            if (i !== instruction) begin
                $display("FAIL: expected=%d instruction=%d pc=%b", i, instruction, program_count);
            end else begin
                $display("PASS: expected=%d instruction=%d pc_d=%d, pc_b=%b", i, instruction, program_count, program_count);
            end
        end
    end
    //instruction_mem_test.mem: each line counts upwards in hex from 0 to 255
    //this testbench assumes instruction_mem_test.mem is the file begin loaded
endmodule
