module control_unit_tb;

    opcode_t opcode;
    mem_to_reg_t mem_to_reg;
    alu_op_t alu_op;
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

    task check (input opcode_t test_opcode,
                input expect_branch,
                input expect_mem_read,
                input expect_mem_write,
                input mem_to_reg_t expect_mem_to_reg,
                input alu_op_t expect_alu_op,
                input expect_alu_src_b,
                input expect_alu_src_a,
                input expect_reg_write,
                input expect_jump);
        begin
            opcode = test_opcode;
            failed = 0;
            
            #1;

            $display("opcode=%s", opcode.name());
            
            if (expect_branch !== branch_ctrl) begin
                $display("FAIL: branch error - branch=%b expected=%h", branch_ctrl, expect_branch);
                failed = 1;
            end
            
            if (expect_mem_read !== mem_read || expect_mem_write !== mem_write) begin
                $display("FAIL: mem r/w error - mem_read=%b mem_wrtie=%b expected_read=%b expected_write=%b", mem_read, mem_write, expect_mem_read, expect_mem_write);
                failed = 1;
            end
            
            if (expect_mem_to_reg !== mem_to_reg) begin
                $display("FAIL: mem_to_reg error -- mem_to_reg=%s expected=%s", mem_to_reg.name(), expect_mem_to_reg.name());
                failed = 1;
            end
            
            if (expect_alu_op !== alu_op || expect_alu_src_b !== alu_src_b || expect_alu_src_a !== alu_src_a) begin
                $display("FAIL: ALU related error -- alu_op=%s alu_src_b=%b expected_op=%s expected_src_b=%b alu_src_a=%b expected_src_a=%b", alu_op.name(), alu_src_b, expect_alu_op.name(), expect_alu_src_b, alu_src_a, expect_alu_src_a);
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
                $display("PASS: opcode=%s", opcode.name());
        end
    endtask

    initial begin
        check(.test_opcode       (OP_BRANCH),
              .expect_branch     (1'b1),
              .expect_alu_src_b  (1'b0),
              .expect_alu_src_a  (1'b0),
              .expect_alu_op     (ALUOP_SUB),
              .expect_mem_to_reg (MEM_TO_REG_ALU),
              .expect_reg_write  (1'b0),
              .expect_mem_read   (1'b0),
              .expect_mem_write  (1'b0),
              .expect_jump       (1'b0));
        
        check(.test_opcode       (OP_RTYPE),
              .expect_branch     (1'b0),
              .expect_alu_src_b  (1'b0),
              .expect_alu_src_a  (1'b0),
              .expect_alu_op     (ALUOP_RTYPE),
              .expect_mem_to_reg (MEM_TO_REG_ALU),
              .expect_reg_write  (1'b1),
              .expect_mem_read   (1'b0),
              .expect_mem_write  (1'b0),
              .expect_jump       (1'b0));

        check(.test_opcode       (OP_ALU_IMM),
              .expect_branch     (1'b0),
              .expect_alu_src_b  (1'b1),
              .expect_alu_src_a  (1'b0),
              .expect_alu_op     (ALUOP_RTYPE),
              .expect_mem_to_reg (MEM_TO_REG_ALU),
              .expect_reg_write  (1'b1),
              .expect_mem_read   (1'b0),
              .expect_mem_write  (1'b0),
              .expect_jump       (1'b0));

        check(.test_opcode       (OP_LOAD),
              .expect_branch     (1'b0),
              .expect_alu_src_b  (1'b1),
              .expect_alu_src_a  (1'b0),
              .expect_alu_op     (ALUOP_ADD),
              .expect_mem_to_reg (MEM_TO_REG_MEM),
              .expect_reg_write  (1'b1),
              .expect_mem_read   (1'b1),
              .expect_mem_write  (1'b0),
              .expect_jump       (1'b0));

        check(.test_opcode       (OP_JALR),
              .expect_branch     (1'b0),
              .expect_alu_src_b  (1'b1),
              .expect_alu_src_a  (1'b0),
              .expect_alu_op     (ALUOP_ADD),
              .expect_mem_to_reg (MEM_TO_REG_PC4),
              .expect_reg_write  (1'b1),
              .expect_mem_read   (1'b0),
              .expect_mem_write  (1'b0),
              .expect_jump       (1'b1));

        check(.test_opcode       (OP_STORE),
              .expect_branch     (1'b0),
              .expect_alu_src_b  (1'b1),
              .expect_alu_src_a  (1'b0),
              .expect_alu_op     (ALUOP_ADD),
              .expect_mem_to_reg (MEM_TO_REG_ALU),
              .expect_reg_write  (1'b0),
              .expect_mem_read   (1'b0),
              .expect_mem_write  (1'b1),
              .expect_jump       (1'b0));
        
        check(.test_opcode       (OP_JAL),
              .expect_branch     (1'b0),
              .expect_alu_src_b  (1'b1),
              .expect_alu_src_a  (1'b1),
              .expect_alu_op     (ALUOP_ADD),
              .expect_mem_to_reg (MEM_TO_REG_PC4),
              .expect_reg_write  (1'b1),
              .expect_mem_read   (1'b0),
              .expect_mem_write  (1'b0),
              .expect_jump       (1'b1));

        check(.test_opcode       (OP_LUI),
              .expect_branch     (1'b0),
              .expect_alu_src_b  (1'b1),
              .expect_alu_src_a  (1'b0),
              .expect_alu_op     (ALUOP_LUI),
              .expect_mem_to_reg (MEM_TO_REG_ALU),
              .expect_reg_write  (1'b1),
              .expect_mem_read   (1'b0),
              .expect_mem_write  (1'b0),
              .expect_jump       (1'b0));

        check(.test_opcode       (OP_AUIPC),
              .expect_branch     (1'b0),
              .expect_alu_src_b  (1'b1),
              .expect_alu_src_a  (1'b1),
              .expect_alu_op     (ALUOP_ADD),
              .expect_mem_to_reg (MEM_TO_REG_ALU),
              .expect_reg_write  (1'b1),
              .expect_mem_read   (1'b0),
              .expect_mem_write  (1'b0),
              .expect_jump       (1'b0));
    end
endmodule
