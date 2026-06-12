import riscv_pkg::*;

module program_count_tb;
    branch_funct3_t funct3;
    jump_t          jump;
    reg clk, reset, branch_ctrl, zero, negative, overflow, carry;
    reg [31:0] pc_in, pc_out, pc_plus_4, alu_result, imm, pc_plus_imm;
    
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
                       .imm         (imm),
                       .pc_plus_4   (pc_plus_4),
                       .pc_plus_imm (pc_plus_imm),
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

    task check (input [31:0] expected_pc,
                input [31:0] expected_pc_plus_4,
                input [31:0] expected_pc_plus_imm);
        begin
            
            tick();
            
            $display("funct3=%s pc_in=%h alu_result=%h pc+4=%h jump=%s branch=%b carry=%b zero=%b overflow=%b negative=%b pc_out=%h pc+imm=%h", funct3.name(), pc_in, alu_result, pc_plus_4, jump.name(), branch_ctrl, carry, zero, overflow, negative, pc_out, pc_plus_imm);
            
            if (expected_pc !== pc_out || expected_pc_plus_4 !== pc_plus_4 || expected_pc_plus_imm !== pc_plus_imm)
                $display("FAIL: pc=%h expected=%h pc+4=%h expected+4=%h pc+imm=%h expected+imm%h",
                         pc_out, expected_pc, pc_plus_4, expected_pc_plus_4, pc_plus_imm, expected_pc_plus_imm);
        end
    endtask

    initial begin
        //test reset, none of these signals but reset should matter
        reset       = 1;
        funct3      = FUNCT3_BEQ;
        jump        = JUMP_NONE;
        branch_ctrl = 1'b1;
        pc_in       = 32'h0F0F_F0F0;
        carry       = 1'b1;
        zero        = 1'b1;
        negative    = 1'b1;
        overflow    = 1'b0;
        alu_result  = 32'hFFFF_FFFF;
        imm         = 32'h0000_FFFF;
        check(32'h0, 32'h0F0F_F0F4, pc_in+imm);
        reset = 0;

        //JAL check
        funct3      = FUNCT3_BGEU;
        jump        = JUMP_JAL;
        branch_ctrl = 1'bx;
        pc_in       = 32'h0000_0000;
        carry       = 1'bx;
        zero        = 1'bx;
        negative    = 1'bx;
        overflow    = 1'b0;
        alu_result  = 32'h0000_000F;
        imm         = 32'h0000_FFFF;
        check(32'h0000_FFFF, 32'h0000_0004, pc_in+imm);

        //JALR check
        funct3      = FUNCT3_BGEU;
        jump        = JUMP_JALR;
        branch_ctrl = 1'bx;
        pc_in       = 32'h0000_0000;
        carry       = 1'bx;
        zero        = 1'bx;
        negative    = 1'bx;
        overflow    = 1'b0;
        alu_result  = 32'h0000_000F;
        imm         = 32'h0000_FFFF;
        check(32'h0000_000E, 32'h0000_0004, pc_in+imm); //bit 0 must be 0 for pc_out JALR

        //BEQ check (branch taken)
        funct3      = FUNCT3_BEQ;
        jump        = JUMP_NONE;
        branch_ctrl = 1'b1;
        pc_in       = 32'h0000_0000;
        carry       = 1'bx;
        zero        = 1'b1;
        negative    = 1'bx;
        overflow    = 1'b0;
        alu_result  = 32'h0000_EEEE;
        imm         = 32'h0C00_DDDD;
        check(32'h0C00_DDDD, 32'h0000_0004, pc_in+imm);

        //BEQ check (branch not taken)
        funct3      = FUNCT3_BEQ;
        jump        = JUMP_NONE;
        branch_ctrl = 1'b1;
        pc_in       = 32'h0000_0000;
        carry       = 1'bx;
        zero        = 1'b0;
        negative    = 1'bx;
        overflow    = 1'b0;
        alu_result  = 32'h0000_EEEE;
        imm         = 32'hFFFF_FFFF;
        check(32'h0000_0004, 32'h0000_0004, pc_in+imm);

        //BNE check (branch taken)
        funct3      = FUNCT3_BNE;
        jump        = JUMP_NONE;
        branch_ctrl = 1'b1;
        pc_in       = 32'h0000_0000;
        carry       = 1'bx;
        zero        = 1'b0;
        negative    = 1'bx;
        overflow    = 1'b0;
        alu_result  = 32'h0000_DDDD;
        imm         = 32'hFFFF_FFFF;
        check(32'hFFFF_FFFF, 32'h0000_0004, pc_in+imm);

        //BNE check (branch not taken)
        funct3      = FUNCT3_BNE;
        jump        = JUMP_NONE;
        branch_ctrl = 1'b1;
        pc_in       = 32'h0000_0000;
        carry       = 1'bx;
        zero        = 1'b1;
        negative    = 1'bx;
        overflow    = 1'b0;
        alu_result  = 32'h0000_EEEE;
        imm         = 32'hFFFF_FFFF;
        check(32'h0000_0004, 32'h0000_0004, pc_in+imm);

        //BLT check (branch taken)
        funct3      = FUNCT3_BLT;
        jump        = JUMP_NONE;
        branch_ctrl = 1'b1;
        pc_in       = 32'h0000_0808;
        carry       = 1'bx;
        zero        = 1'b0;
        negative    = 1'b1;
        overflow    = 1'b0;
        alu_result  = 32'h0000_AFDE;
        imm         = 32'h0000_0004;
        check(32'h0000_080C, 32'h0000_080C, pc_in+imm);

        //BLT check (branch not taken)
        funct3      = FUNCT3_BLT;
        jump        = JUMP_NONE;
        branch_ctrl = 1'b1;
        pc_in       = 32'h0000_000C;
        carry       = 1'bx;
        zero        = 1'b0;
        negative    = 1'b1;
        overflow    = 1'b1;
        alu_result  = 32'h0000_EEEE;
        imm         = 32'hFFFF_FFFF;
        check(32'h0000_0010, 32'h0000_0010, pc_in+imm);

        //BGE check (branch taken)
        funct3      = FUNCT3_BGE;
        jump        = JUMP_NONE;
        branch_ctrl = 1'b1;
        pc_in       = 32'h0000_0000;
        carry       = 1'bx;
        zero        = 1'b0;
        negative    = 1'b0;
        overflow    = 1'b0;
        alu_result  = 32'h00CC_AFDE;
        imm         = 32'h0000_FFFF;
        check(32'h0000_FFFF, 32'h0000_0004, pc_in+imm);

        //BGE check (branch not taken)
        funct3      = FUNCT3_BGE;
        jump        = JUMP_NONE;
        branch_ctrl = 1'b1;
        pc_in       = 32'h000F_0004;
        carry       = 1'bx;
        zero        = 1'b0;
        negative    = 1'b0;
        overflow    = 1'b1;
        alu_result  = 32'hFFFF_EEEE;
        imm         = 32'hFFFF_FFFF;
        check(32'h000F_0008, 32'h000F_0008, pc_in+imm);

        //BLTU check (branch taken)
        funct3      = FUNCT3_BLTU;
        jump        = JUMP_NONE;
        branch_ctrl = 1'b1;
        pc_in       = 32'h0000_0000;
        carry       = 1'b1;
        zero        = 1'b0;
        negative    = 1'b0;
        overflow    = 1'b0;
        alu_result  = 32'h0DCC_AFDE;
        imm         = 32'h0DCC_0008;
        check(32'h0DCC_0008, 32'h0000_0004, pc_in+imm);

        //BLTU check (branch not taken)
        funct3      = FUNCT3_BLTU;
        jump        = JUMP_NONE;
        branch_ctrl = 1'b1;
        pc_in       = 32'h000F_0004;
        carry       = 1'b0;
        zero        = 1'b0;
        negative    = 1'b0;
        overflow    = 1'b1;
        alu_result  = 32'hFFFF_EEEE;
        imm         = 32'hFFFF_FFFF;
        check(32'h000F_0008, 32'h000F_0008, pc_in+imm);

        //BGEU check (branch taken)
        funct3      = FUNCT3_BGEU;
        jump        = JUMP_NONE;
        branch_ctrl = 1'b1;
        pc_in       = 32'h0000_0004;
        carry       = 1'b0;
        zero        = 1'b0;
        negative    = 1'b0;
        overflow    = 1'b0;
        alu_result  = 32'h0DCC_AFDE;
        imm         = 32'hF003_0000;
        check(32'hF003_0004, 32'h0000_0008, pc_in+imm);

        //BGEU check (branch not taken)
        funct3      = FUNCT3_BGEU;
        jump        = JUMP_NONE;
        branch_ctrl = 1'b1;
        pc_in       = 32'h000F_0004;
        carry       = 1'b1;
        zero        = 1'b0;
        negative    = 1'b0;
        overflow    = 1'b1;
        alu_result  = 32'hFFFF_EEEE;
        imm         = 32'hFFFF_FFFF;
        check(32'h000F_0008, 32'h000F_0008, pc_in+imm);

        //non jump non branch test (should be PC+4)
        funct3      = FUNCT3_BGE;
        jump        = JUMP_NONE;
        branch_ctrl = 1'b0;
        pc_in       = 32'h000F_0008;
        carry       = 1'b1;
        zero        = 1'b0;
        negative    = 1'b0;
        overflow    = 1'b1;
        alu_result  = 32'hFFFF_EEEE;
        imm         = 32'hFFFF_FFFF;
        check(32'h000F_000C, 32'h000F_000C, pc_in+imm);

        //JALR LSB clearing test
        funct3      = FUNCT3_BGE;
        jump        = JUMP_JALR;
        branch_ctrl = 1'b0;
        pc_in       = 32'h0000_0000;
        carry       = 1'b1;
        zero        = 1'b0;
        negative    = 1'b0;
        overflow    = 1'b1;
        alu_result  = 32'h0000_0005;
        imm         = 32'hFFFF_FFFF;
        check(32'h0000_0004, 32'h0000_0004, pc_in+imm);

        //AUIPC
        funct3      = FUNCT3_BGE;
        jump        = JUMP_NONE;
        branch_ctrl = 1'b0;
        pc_in       = 32'h0000_0000;
        carry       = 1'b1;
        zero        = 1'b0;
        negative    = 1'b0;
        overflow    = 1'b1;
        alu_result  = 32'h0000_0005;
        imm         = 32'hFFFF_FFFF;
        check(32'h0000_0004, 32'h0000_0004, pc_in+imm);
    end
endmodule    
