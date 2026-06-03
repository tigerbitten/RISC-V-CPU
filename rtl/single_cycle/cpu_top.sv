import riscv_pkg::*;

module cpu_top(input clk,
               input reset);

    //Control Unit Signals
    wire branch_ctrl, reg_write, alu_src_b, mem_read, mem_write;
    mem_to_reg_t mem_to_reg;
    alu_op_t     alu_op;
    jump_t       jump;
    
    //PC Signals
    wire [31:0] pc_out, pc_plus_4;

    //Instruction Memory Signals
    wire [31:0] instruction;

    //Register File Signals
    wire [31:0] rs1_data, rs2_data;
    reg [31:0]  rd_data;

    //Imm Gen Signals
    wire [31:0] imm;

    //ALU Control Signals
    alu_control_t  alu_control;

    //ALU Signals
    wire        zero, carry, overflow, negative;
    wire [31:0] a, b, alu_result;

    //Data Memory Signals
    wire [31:0] read_data;
    
    program_count pc (.clk         (clk),
                      .reset       (reset),
                      .funct3      (instruction[14:12]),
                      .pc_in       (pc_out),
                      .jump        (jump),
                      .branch_ctrl (branch_ctrl),
                      .zero        (zero),
                      .negative    (negative),
                      .overflow    (overflow),
                      .carry       (carry),
                      .alu_result  (alu_result),
                      .imm         (imm),
                      .pc_plus_4   (pc_plus_4),
                      .pc_out      (pc_out));

    instruction_memory #(.MEM_FILE("program_test_1.mem")) imem (.program_count (pc_out),
                                                                .instruction   (instruction));

    register_file reg_file (.clk       (clk),
                            .reset     (reset),
                            .reg_write (reg_write),
                            .rs1_addr  (instruction[19:15]),
                            .rs2_addr  (instruction[24:20]),
                            .rd_addr   (instruction[11:7]),
                            .rd_data   (rd_data),
                            .rs1_data  (rs1_data),
                            .rs2_data  (rs2_data));
    
    imm_gen igen (.instruction (instruction),
                  .imm         (imm));

    alu_control alu_ctrl (.alu_op      (alu_op),
                          .funct3      (instruction[14:12]),
                          .funct7_30   (instruction[30]),
                          .alu_control (alu_control));

    control_unit ctrl_unit (.opcode      (instruction[6:0]),
                            .alu_op      (alu_op),
                            .alu_src_b   (alu_src_b),
                            .branch_ctrl (branch_ctrl),
                            .jump        (jump),
                            .mem_read    (mem_read),
                            .mem_write   (mem_write),
                            .mem_to_reg  (mem_to_reg),
                            .reg_write   (reg_write));

    //MUX to ALU b input
    assign b = (alu_src_b) ? imm    : rs2_data;

    ALU alu (.a           (rs1_data),
             .b           (b),
             .alu_control (alu_control),
             .result      (alu_result),
             .zero        (zero),
             .negative    (negative),
             .overflow    (overflow),
             .carry       (carry));

    data_memory data_mem (.clk        (clk),
                          .mem_read   (mem_read),
                          .mem_write  (mem_write),
                          .write_data (rs2_data),
                          .address    (alu_result),
                          .funct3     (instruction[14:12]),
                          .read_data  (read_data));

    //Writeback MUX
    always_comb begin
        case(mem_to_reg)
          MEM_TO_REG_ALU : rd_data = alu_result;
          MEM_TO_REG_MEM : rd_data = read_data;
          MEM_TO_REG_PC4 : rd_data = pc_plus_4;
        endcase
    end
endmodule
