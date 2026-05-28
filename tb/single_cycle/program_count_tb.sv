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
            
            tick();
            
            $display("funct3=%s pc_in=%h alu_result=%h jump=%b branch=%b carry=%b zero=%b overflow=%b negative=%b pc_out=%h", funct3.name(), pc_in, alu_result, jump, branch_ctrl, carry, zero, overflow, negative, pc_out);
            
            if (expected_pc !== pc_out)
                $display("FAIL: pc_out=%h expected=%h", pc_out, expected_pc);
        end
    endtask

    initial begin
        //test reset, none of these signals but reset should matter
        reset       = 1;
        funct3      = FUNCT3_BEQ;
        jump        = 1'b1;
        branch_ctrl = 1'b1;
        pc_in       = 32'h0F0F_F0F0;
        carry       = 1'b1;
        zero        = 1'b1;
        negative    = 1'b1;
        alu_result  = 32'hFFFF_FFFF;
        check(32'h0);
        reset = 0;

        //JAL check
        funct3      = FUNCT3_BGEU;
        jump        = 1'b1;
        branch_ctrl = 1'bx;
        pc_in       = 32'hFFFF_FFFF;
        carry       = 1'bx;
        zero        = 1'bx;
        negative    = 1'bx;
        alu_result  = 32'h0000_000F;
        check(32'h0000_000F);

        /*
        //BNE check (branch taken)
        funct3      = FUNCT3_BNE;
        jump        = 1'b0;
        branch_ctrl = 1'b1;
        pc_in       = 32'h1234_5678;
        carry       = 1'bx;
        zero        = 1'b1;
        negative    = 1'bx;
        alu_result  = 32'h0000_EEEE;
        check(32'h0000_000F);
*/
    end
endmodule    
