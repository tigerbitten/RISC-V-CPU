module control_unit_tb;

    reg [6:0] opcode;
    reg [1:0] alu_op, mem_to_reg;
    reg       branch_ctrl, mem_read, mem_write, alu_src, reg_write, jump;
    
    control_unit DUT (.opcode      (opcode),
                      .branch_ctrl (branch_ctrl),
                      .mem_read    (mem_read),
                      .mem_write   (mem_write),
                      .mem_to_reg  (mem_to_reg),
                      .alu_op      (alu_op),
                      .alu_src     (alu_src),
                      .reg_write   (reg_write),
                      .jump        (jump));

    task check (input [6:0] test_opcode,
                input       expect_branch,
                input       expect_mem_read,
                input       expect_mem_write,
                input [1:0] expect_mem_to_reg,
                input [1:0] expect_alu_op,
                input       expect_alu_src,
                input       expect_reg_write,
                input       expect_jump);
        begin
            opcode = test_opcode;
            
            #1;

            if (expect_branch !== branch_ctrl)
                $display("FAIL: branch error - branch=%b expected=%h", branch_ctrl, expect_branch);
            if (expect_mem_read !== mem_read || expect_mem_write !== mem_write)
                $display("FAIL: mem r/w error - mem_read=%b mem_wrtie=%b expected_read=%b expected_write=%b", mem_read, mem_write, expect_mem_read, expect_mem_write);
            if (expect_mem_to_reg !== mem_to_reg)
                $display("FAIL: mem_to_reg error -- mem_to_reg=%b expected=%b", mem_to_reg, expect_mem_to_reg);
            if (expect_alu_op !== alu_op || expect_alu_src !== alu_src)
                $display("FAIL: ALU related error -- alu_op=%b alu_src=%b expected_op=%b expected_src=%b", alu_op, alu_src, expect_alu_op, expect_alu_src);
            if (expect_reg_write !== reg_write)
                $display("FAIL: reg_write error -- reg_write=%b expected=%b", reg_write, expect_reg_write);
            if (expect_jump !== jump)
                $display("FAIL: jump error -- jump=%b expected=%b", jump, expect_jump);
        end
    endtask

    initial begin
        check(.test_opcode       (7'b1100011),
              .expect_branch     (1'b1),
              .expect_alu_src    (1'b0),
              .expect_alu_op     (2'b01),
              .expect_mem_to_reg (2'b00),
              .expect_reg_write  (1'b0),
              .expect_mem_read   (1'b0),
              .expect_mem_write  (1'b0),
              .expect_jump       (1'b0));
    end
endmodule
