import riscv_pkg::*;

module program_count_tb;
    branch_funct3_t funct3;
    reg clk, reset, branch_ctrl, zero, negative, overflow, carry, jump;
    reg [31:0] pc_in, pc_out, alu_result;
    
    program_count dut (.clk         (clk),
                       .reset       (reset),
                       .funct3      (funct3),
                       .pc_in       (pc_in),
                       .jump        (jump),
                       .branch_ctrl (branch_ctrl),
                       .zero        (zero),
                       .negative    (negative),
                       .overflow    (overflow),
                       .carry       (carry),
                       .alu_result  (alu_result),
                       .pc_out      (pc_out));

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

    task check (input [31:0] expected_pc);
        begin
            $display("funct3=%s pc_in=%h alu_result=%h jump=%b branch=%b carry=%b zero=%b overflow=%b negative=%b", funct3.name(), pc_in, alu_result, jump, branch_ctrl, carry, zero, overflow, negative);
            
            if (expected_pc !== pc_out)
                $display("FAIL: pc_out=%h expected=%h", pc_out, expected_pc);
        end
    endtask
                           
endmodule    
