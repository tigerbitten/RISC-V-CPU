import riscv_pkg::*;

module cpu_top #(parameter MEM_FILE = "current_test.mem") 
    (input clk,
     input reset);

    //IF Stage
    wire [31:0] pc_plus_4, pc_out, instruction;

    program_count pc (.clk         (clk),
                      .reset       (reset),
                      .stall       (stall),
                      .next_pc     (next_pc),
                      .pc_plus_4   (pc_plus_4),
                      .pc_out      (pc_out));
    
    instruction_memory #(.MEM_FILE(MEM_FILE)) imem (.program_count (pc_out),
                                                    .instruction   (instruction));

    //IF / ID Register
    reg [31:0] id_pc_plus_4, id_pc_out, id_instruction;

    always_ff @(posedge clk) begin
        if (reset) begin
            id_pc_plus_4   <= 32'b0;
            id_pc_out      <= 32'b0;
            id_instruction <= 32'b0;
        end else if (stall) begin
            //hold current vals -- do nothing;
        end else begin
            id_pc_plus_4   <= pc_plus_4;
            id_pc_out      <= pc_out;
            id_instruction <= instruction;
        end
    end

    //ID Stage
    wire branch_ctrl, reg_write, alu_src_b, mem_read, mem_write, stall;
    wire [31:0] rs1_data, rs2_data, imm;
    wire [4:0]  id_rs1_addr, id_rs2_addr;
    mem_to_reg_t mem_to_reg;
    alu_op_t     alu_op;
    jump_t       jump;

    assign id_rs1_addr = id_instruction[19:15];
    assign id_rs2_addr = id_instruction[24:20];

    hazard_unit hazard_u (.ex_mem_read (ex_mem_read),
                          .ex_rd_addr  (ex_rd_addr),
                          .id_rs1_addr (id_rs1_addr),
                          .id_rs2_addr (id_rs2_addr),
                          .stall       (stall));
    
    control_unit ctrl_unit (.opcode      (id_instruction[6:0]),
                            .alu_op      (alu_op),
                            .alu_src_b   (alu_src_b),
                            .branch_ctrl (branch_ctrl),
                            .jump        (jump),
                            .mem_read    (mem_read),
                            .mem_write   (mem_write),
                            .mem_to_reg  (mem_to_reg),
                            .reg_write   (reg_write));

    register_file reg_file (.clk       (clk),
                            .reset     (reset),
                            .reg_write (wb_reg_write),
                            .rs1_addr  (id_rs1_addr),
                            .rs2_addr  (id_rs2_addr),
                            .rd_addr   (wb_rd_addr),
                            .rd_data   (wb_rd_data),
                            .rs1_data  (rs1_data),
                            .rs2_data  (rs2_data));
    
    imm_gen igen (.instruction (id_instruction),
                  .imm         (imm));


    //ID / EX Register
    reg ex_branch_ctrl, ex_alu_src_b, ex_mem_read, ex_mem_write, ex_reg_write, ex_funct7_30;
    reg [31:0] ex_rs1_data, ex_rs2_data, ex_imm, ex_pc_plus_4, ex_pc_out;
    reg [2:0]  ex_funct3;
    reg [4:0]  ex_rd_addr, ex_rs1_addr, ex_rs2_addr;
    mem_to_reg_t ex_mem_to_reg;
    alu_op_t     ex_alu_op;
    jump_t       ex_jump;
    wire         flush = stall;

    always_ff @(posedge clk) begin
        if (reset || flush) begin
            ex_branch_ctrl <= 1'b0;
            ex_alu_src_b   <= 1'b0;
            ex_mem_read    <= 1'b0;
            ex_mem_write   <= 1'b0;
            ex_reg_write   <= 1'b0;
            ex_funct7_30   <= 1'b0;
            ex_funct3      <= 3'b0;
            ex_rd_addr     <= 5'b0;
            ex_rs1_addr    <= 5'b0;
            ex_rs2_addr    <= 5'b0;
            ex_rs1_data    <= 32'b0;
            ex_rs2_data    <= 32'b0;
            ex_imm         <= 32'b0;
            ex_pc_plus_4   <= 32'b0;
            ex_pc_out      <= 32'b0;
            ex_mem_to_reg  <= MEM_TO_REG_ALU;
            ex_alu_op      <= ALUOP_ADD;
            ex_jump        <= JUMP_NONE;
        end else begin
            ex_branch_ctrl <= branch_ctrl;
            ex_alu_src_b   <= alu_src_b;
            ex_mem_read    <= mem_read;
            ex_mem_write   <= mem_write;
            ex_reg_write   <= reg_write;
            ex_funct7_30   <= id_instruction[30];
            ex_funct3      <= id_instruction[14:12];
            ex_rd_addr     <= id_instruction[11:7];
            ex_rs1_addr    <= id_rs1_addr;
            ex_rs2_addr    <= id_rs2_addr;
            ex_rs1_data    <= rs1_data;
            ex_rs2_data    <= rs2_data;
            ex_imm         <= imm;
            ex_pc_plus_4   <= id_pc_plus_4;
            ex_pc_out      <= id_pc_out;
            ex_mem_to_reg  <= mem_to_reg;
            ex_alu_op      <= alu_op;
            ex_jump        <= jump;
        end
    end

    //EX Stage
    wire        zero, carry, overflow, negative;
    wire [31:0] alu_b, alu_result, pc_plus_imm, next_pc;
    reg [31:0]  a_forwarded, b_forwarded;
    forward_select_t forward_a_select, forward_b_select;
    alu_control_t  alu_control;

    forwarding_unit fwrd_u (.ex_rs1_addr      (ex_rs1_addr),
                            .ex_rs2_addr      (ex_rs2_addr),
                            .mem_rd_addr      (mem_rd_addr),
                            .mem_reg_write    (mem_reg_write),
                            .wb_rd_addr       (wb_rd_addr),
                            .wb_reg_write     (wb_reg_write),
                            .forward_a_select (forward_a_select),
                            .forward_b_select (forward_b_select));
    
    alu_control alu_ctrl (.alu_op      (ex_alu_op),
                          .funct3      (ex_funct3),
                          .funct7_30   (ex_funct7_30),
                          .alu_control (alu_control));
    
    //Forwarding MUXES
    always_comb begin
        case (forward_a_select)
          FWD_MEM  : a_forwarded = mem_alu_result;
          FWD_WB   : a_forwarded = wb_rd_data;
          FWD_NONE : a_forwarded = ex_rs1_data;
        endcase
    end

    always_comb begin
        case (forward_b_select)
          FWD_MEM  : b_forwarded = mem_alu_result;
          FWD_WB   : b_forwarded = wb_rd_data;
          FWD_NONE : b_forwarded = ex_rs2_data;
        endcase
    end

    //second MUX to ALU b input
    assign alu_b = (ex_alu_src_b) ? ex_imm : b_forwarded;

    ALU alu (.a           (a_forwarded),
             .b           (alu_b),
             .alu_control (alu_control),
             .result      (alu_result),
             .zero        (zero),
             .negative    (negative),
             .overflow    (overflow),
             .carry       (carry));

    next_pc_unit next_pc_u (.funct3      (ex_funct3),
                            .jump        (ex_jump),
                            .branch_ctrl (ex_branch_ctrl),
                            .zero        (zero),
                            .negative    (negative),
                            .overflow    (overflow),
                            .carry       (carry),
                            .alu_result  (alu_result),
                            .imm         (ex_imm),
                            .pc_plus_4   (ex_pc_plus_4),
                            .pc_out      (ex_pc_out),
                            .pc_plus_imm (pc_plus_imm),
                            .next_pc     (next_pc));

    //EX / MEM Register
    reg [31:0] mem_alu_result, mem_pc_plus_imm, mem_rs2_data, mem_pc_plus_4;
    reg        mem_mem_read, mem_mem_write, mem_reg_write;
    mem_to_reg_t mem_mem_to_reg;
    reg [4:0]  mem_rd_addr;
    reg [2:0]  mem_funct3;

    always_ff @(posedge clk) begin
        if (reset) begin
            mem_mem_to_reg  <= MEM_TO_REG_ALU;
            mem_mem_read    <= 1'b0;
            mem_mem_write   <= 1'b0;
            mem_reg_write   <= 1'b0;
            mem_rd_addr     <= 5'b0;
            mem_funct3      <= 3'b0;
            mem_alu_result  <= 32'b0;
            mem_pc_plus_imm <= 32'b0;
            mem_pc_plus_4   <= 32'b0;
            mem_rs2_data    <= 32'b0;
        end else begin
            mem_mem_to_reg  <= ex_mem_to_reg;
            mem_mem_read    <= ex_mem_read;
            mem_mem_write   <= ex_mem_write;
            mem_reg_write   <= ex_reg_write;
            mem_rd_addr     <= ex_rd_addr;
            mem_funct3      <= ex_funct3;
            mem_alu_result  <= alu_result;
            mem_pc_plus_imm <= pc_plus_imm;
            mem_pc_plus_4   <= ex_pc_plus_4;
            mem_rs2_data    <= ex_rs2_data;
        end
    end

    //MEM Stage
    wire [31:0] read_data;

    data_memory data_mem (.clk        (clk),
                          .mem_read   (mem_mem_read),
                          .mem_write  (mem_mem_write),
                          .write_data (mem_rs2_data),
                          .address    (mem_alu_result),
                          .funct3     (mem_funct3),
                          .read_data  (read_data));

    //MEM / WB Register
    reg [31:0] wb_read_data, wb_alu_result, wb_pc_plus_4, wb_pc_plus_imm;
    reg [4:0]  wb_rd_addr;
    reg        wb_reg_write;
    mem_to_reg_t wb_mem_to_reg;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            wb_read_data   <= 32'b0;
            wb_alu_result  <= 32'b0;
            wb_pc_plus_4   <= 32'b0;
            wb_pc_plus_imm <= 32'b0;
            wb_rd_addr     <= 5'b0;
            wb_mem_to_reg  <= MEM_TO_REG_ALU;
            wb_reg_write   <= 1'b0;
        end else begin
            wb_read_data   <= read_data;
            wb_alu_result  <= mem_alu_result;
            wb_pc_plus_4   <= mem_pc_plus_4;
            wb_pc_plus_imm <= mem_pc_plus_imm;
            wb_rd_addr     <= mem_rd_addr;
            wb_mem_to_reg  <= mem_mem_to_reg;
            wb_reg_write   <= mem_reg_write;
        end
    end
    
    //Writeback MUX
    reg [31:0] wb_rd_data;
    
    always_comb begin
        case(wb_mem_to_reg)
          MEM_TO_REG_ALU   : wb_rd_data = wb_alu_result;
          MEM_TO_REG_MEM   : wb_rd_data = wb_read_data;
          MEM_TO_REG_PC4   : wb_rd_data = wb_pc_plus_4;
          MEM_TO_REG_AUIPC : wb_rd_data = wb_pc_plus_imm;
        endcase
    end
endmodule
