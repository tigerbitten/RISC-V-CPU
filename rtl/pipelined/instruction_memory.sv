module instruction_memory #(parameter MEM_FILE = "current_test.mem")
    (input [31:0]  program_count,
     output [31:0] instruction);
    
    reg [31:0] memory [2047:0];
    
    assign instruction = memory[program_count >> 2]; //divide by 4

    initial begin
        $readmemh(MEM_FILE, memory);
    end
endmodule
