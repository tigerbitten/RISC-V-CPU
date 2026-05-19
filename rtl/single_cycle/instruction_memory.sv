module instruction_memory(input [31:0]  program_count,
                          output [31:0] instruction);
    reg [31:0] memory [255:0];
    
    assign instruction = memory[program_count >> 2]; //divide by 4

    initial begin
        $readmemh("instruction_mem_test.mem", memory);
    end
endmodule
