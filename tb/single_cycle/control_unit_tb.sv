module control_unit_tb;

    reg [6:0] opcode;
    reg [1:0] alu_op, mem_to_reg;
    reg       branch_ctrl, mem_read, mem_write, alu_src_b, alu_src_a, reg_write, jump;
    integer   failed;
    
    control_unit DUT (.opcode      (opcode),
                      .branch_ctrl (branch_ctrl),
                      .mem_read    (mem_read),
                      .mem_write   (mem_write),
                      .mem_to_reg  (mem_to_reg),
                      .alu_op      (alu_op),
                      .alu_src_b   (alu_src_b),
                      .alu_src_a   (alu_src_a),
                      .reg_write   (reg_write),
                      .jump        (jump));

    task check (input [6:0] test_opcode,
                input       expect_branch,
                input       expect_mem_read,
                input       expect_mem_write,
                input [1:0] expect_mem_to_reg,
                input [1:0] expect_alu_op,
                input       expect_alu_src_b,
                input       expect_alu_src_a,
                input       expect_reg_write,
                input       expect_jump);
        begin
            opcode = test_opcode;
            failed = 0;
            
            #1;

            $display("opcode=%b", opcode);
            
            if (expect_branch !== branch_ctrl) begin
                $display("FAIL: branch error - branch=%b expected=%h", branch_ctrl, expect_branch);
                failed = 1;
            end
            if (expect_mem_read !== mem_read || expect_mem_write !== mem_write) begin
                $display("FAIL: mem r/w error - mem_read=%b mem_wrtie=%b expected_read=%b expected_write=%b", mem_read, mem_write, expect_mem_read, expect_mem_write);
                failed = 1;
            end
            if (expect_mem_to_reg !== mem_to_reg) begin
                $display("FAIL: mem_to_reg error -- mem_to_reg=%b expected=%b", mem_to_reg, expect_mem_to_reg);
                failed = 1;
            end
            if (expect_alu_op !== alu_op || expect_alu_src_b !== alu_src_b || expect_alu_src_a !== alu_src_a) begin
                $display("FAIL: ALU related error -- alu_op=%b alu_src_b=%b expected_op=%b expected_src_b=%b alu_src_a=%b expected_src_a=%b", alu_op, alu_src_b, expect_alu_op, expect_alu_src_b, alu_src_a, expect_alu_src_a);
                failed = 1;
            end
            if (expect_reg_write !== reg_write) begin
                $display("FAIL: reg_write error -- reg_write=%b expected=%b", reg_write, expect_reg_write);
                failed = 1;
            end
            if (expect_jump !== jump) begin
                $display("FAIL: jump error -- jump=%b expected=%b", jump, expect_jump);
                failed = 1;
            end

            if (!failed)
                $display("PASS: opcode=%b", opcode);
        end
    endtask

    initial begin
        check(.test_opcode       (7'b1100011), //B-Type
              .expect_branch     (1'b1),
              .expect_alu_src_b  (1'b0),
              .expect_alu_src_a  (1'b0),
              .expect_alu_op     (2'b01),
              .expect_mem_to_reg (2'b00),
              .expect_reg_write  (1'b0),
              .expect_mem_read   (1'b0),
              .expect_mem_write  (1'b0),
              .expect_jump       (1'b0));
        
        check(.test_opcode       (7'b0110011), //R-Type
              .expect_branch     (1'b0),
              .expect_alu_src_b  (1'b0),
              .expect_alu_src_a  (1'b0),
              .expect_alu_op     (2'b10),
              .expect_mem_to_reg (2'b00),
              .expect_reg_write  (1'b1),
              .expect_mem_read   (1'b0),
              .expect_mem_write  (1'b0),
              .expect_jump       (1'b0));

        check(.test_opcode       (7'b0010011), //I-Type ALU immediates
              .expect_branch     (1'b0),
              .expect_alu_src_b  (1'b1),
              .expect_alu_src_a  (1'b0),
              .expect_alu_op     (2'b10),
              .expect_mem_to_reg (2'b00),
              .expect_reg_write  (1'b1),
              .expect_mem_read   (1'b0),
              .expect_mem_write  (1'b0),
              .expect_jump       (1'b0));

        check(.test_opcode       (7'b0000011), //I-Type load instructions
              .expect_branch     (1'b0),
              .expect_alu_src_b  (1'b1),
              .expect_alu_src_a  (1'b0),
              .expect_alu_op     (2'b00),
              .expect_mem_to_reg (2'b01),
              .expect_reg_write  (1'b1),
              .expect_mem_read   (1'b1),
              .expect_mem_write  (1'b0),
              .expect_jump       (1'b0));

        check(.test_opcode       (7'b1100111), //I-Type JALR
              .expect_branch     (1'b0),
              .expect_alu_src_b  (1'b1),
              .expect_alu_src_a  (1'b0),
              .expect_alu_op     (2'b00),
              .expect_mem_to_reg (2'b10),
              .expect_reg_write  (1'b1),
              .expect_mem_read   (1'b0),
              .expect_mem_write  (1'b0),
              .expect_jump       (1'b1));

        check(.test_opcode       (7'b0100011), //S-Type instructions
              .expect_branch     (1'b0),
              .expect_alu_src_b  (1'b1),
              .expect_alu_src_a  (1'b0),
              .expect_alu_op     (2'b00),
              .expect_mem_to_reg (2'b00),
              .expect_reg_write  (1'b0),
              .expect_mem_read   (1'b0),
              .expect_mem_write  (1'b1),
              .expect_jump       (1'b0));
        
        check(.test_opcode       (7'b1101111), //J-Type instructions
              .expect_branch     (1'b0),
              .expect_alu_src_b  (1'b1),
              .expect_alu_src_a  (1'b1),
              .expect_alu_op     (2'b00),
              .expect_mem_to_reg (2'b10),
              .expect_reg_write  (1'b1),
              .expect_mem_read   (1'b0),
              .expect_mem_write  (1'b0),
              .expect_jump       (1'b1));

        check(.test_opcode       (7'b0110111), //U-Type LUI
              .expect_branch     (1'b0),
              .expect_alu_src_b  (1'b1),
              .expect_alu_src_a  (1'b0),
              .expect_alu_op     (2'b11),
              .expect_mem_to_reg (2'b00),
              .expect_reg_write  (1'b1),
              .expect_mem_read   (1'b0),
              .expect_mem_write  (1'b0),
              .expect_jump       (1'b0));

        check(.test_opcode       (7'b0010111), //U-Type AUIPC
              .expect_branch     (1'b0),
              .expect_alu_src_b  (1'b1),
              .expect_alu_src_a  (1'b1),
              .expect_alu_op     (2'b00),
              .expect_mem_to_reg (2'b00),
              .expect_reg_write  (1'b1),
              .expect_mem_read   (1'b0),
              .expect_mem_write  (1'b0),
              .expect_jump       (1'b0));
    end
endmodule
