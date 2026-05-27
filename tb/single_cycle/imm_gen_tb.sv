module imm_gen_tb;
    reg [31:0] instruction, imm;
    
    imm_gen DUT (.instruction (instruction),
                 .imm         (imm));

    task check (input [31:0] test_instruction,
                input [31:0] expected_imm);
        begin
            instruction = test_instruction;

            #1;
            
            if (imm !== expected_imm) begin
                $display("FAIL: inst=%b imm=%b expected=%b", instruction, imm, expected_imm);
            end else begin
                $display("PASS: inst=%b imm=%b", instruction, imm);
            end
        end
    endtask

    initial begin
        // I-Type
        check(32'b01111111111100000000000000000011, 32'b00000000000000000000011111111111); //opcode OP_LOAD
        check(32'b01111111111100000000000000010011, 32'b00000000000000000000011111111111); //opcode OP_ALU_IMM
        check(32'b11111111111100000000000001100111, 32'b11111111111111111111111111111111); //opcode OP_JALR

        // S-Type
        check(32'b11111110001000001010111000100011, 32'b11111111111111111111111111111100); //opcode OP_STORE
        check(32'b11111110010100110010111000100011, 32'b11111111111111111111111111111100);
        check(32'b00000000101001001010010000100011, 32'b00000000000000000000000000001000);

        // B-Type
        check(32'b11111110001000001010111001100011, 32'b11111111111111111111011111111100); //opcode OP_BRANCH
        check(32'b11111110001000001000111011100011, 32'b11111111111111111111111111111100);
        check(32'b00000000010100110000010001100011, 32'b00000000000000000000000000001000);

        // U-Type
        check(32'b10101011110011011110010100110111, 32'b10101011110011011110000000000000); //opcode OP_LUI
        check(32'b00010010001101000101011010110111, 32'b00010010001101000101000000000000);
        check(32'b11111111111100000000001010110111, 32'b11111111111100000000000000000000);
        
        // J-Type
        check(32'b00000000100000000000000011101111, 32'b00000000000000000000000000001000); //opcode OP_JAL
        check(32'b11111111110111111111000011101111, 32'b11111111111111111111111111111100);
        check(32'b01010101010010101010000011101111, 32'b00000000000010101010010101010100);

        // R-Type (doesn't have immediate field, should be 0)
        check(32'b00000000000000000000000000110011, 32'd0); //opcode OP_RTYPE

        //reference riscv_pkg.sv for opcode enum type
    end
    
endmodule
