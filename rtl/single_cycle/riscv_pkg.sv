package riscv_pkg;

    typedef enum reg [3:0] {
                            ALU_ADD  = 4'b0010,
                            ALU_SUB  = 4'b0110,
                            ALU_AND  = 4'b0000,
                            ALU_OR   = 4'b0001,
                            ALU_SLL  = 4'b0100,
                            ALU_SLT  = 4'b0111,
                            ALU_SLTU = 4'b1000,
                            ALU_XOR  = 4'b0011,
                            ALU_SRL  = 4'b0101,
                            ALU_SRA  = 4'b1001,
                            ALU_LUI  = 4'b1010
                            } alu_control_t;

    typedef enum reg [2:0] {
                            ALUOP_ADD   = 3'b000,
                            ALUOP_SUB   = 3'b001,
                            ALUOP_RTYPE = 3'b010,
                            ALUOP_ITYPE  = 3'b011,
                            ALUOP_LUI   = 3'b100
                            } alu_op_t;
    
    typedef enum reg [6:0] {
                            OP_RTYPE    = 7'b0110011,
                            OP_ALU_IMM  = 7'b0010011, // (I-Type according to RISC-V)
                            OP_LOAD     = 7'b0000011, // (I-Type according to RISC-V)
                            OP_STORE    = 7'b0100011,
                            OP_BRANCH   = 7'b1100011,
                            OP_JAL      = 7'b1101111,
                            OP_JALR     = 7'b1100111, // (I-Type according to RISC-V)
                            OP_LUI      = 7'b0110111,
                            OP_AUIPC    = 7'b0010111
                            } opcode_t;

    typedef enum reg [2:0] {
                            FUNCT3_BYTE       = 3'b000,
                            FUNCT3_HALFWORD   = 3'b001,
                            FUNCT3_WORD       = 3'b010,
                            FUNCT3_BYTE_U     = 3'b100,
                            FUNCT3_HALFWORD_U = 3'b101
                            } mem_funct3_t;

    typedef enum reg [2:0] {
                            FUNCT3_BEQ  = 3'b000,
                            FUNCT3_BNE  = 3'b001,
                            FUNCT3_BLT  = 3'b100,
                            FUNCT3_BGE  = 3'b101,
                            FUNCT3_BLTU = 3'b110,
                            FUNCT3_BGEU = 3'b111
                            } branch_funct3_t;
    
    typedef enum reg [1:0] {
                            MEM_TO_REG_ALU = 2'b00, //write register file from ALU output
                            MEM_TO_REG_MEM = 2'b01, //write register file from memory
                            MEM_TO_REG_PC4 = 2'b10  //write PC + 4 into register file
                            } mem_to_reg_t;
    
    typedef enum reg [1:0] {
                            JUMP_NONE = 2'b00,
                            JUMP_JALR = 2'b01,
                            JUMP_JAL  = 2'b10
                            } jump_t;
    
    typedef enum reg [1:0] {
                            MEM_WIDTH_BYTE     = 2'b00,
                            MEM_WIDTH_HALFWORD = 2'b01,
                            MEM_WIDTH_WORD     = 2'b10
                            } mem_width_t; //for cpu_top tb
    
endpackage
