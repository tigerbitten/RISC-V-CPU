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

    typedef enum reg [1:0] {
                            ALUOP_ADD   = 2'b00,
                            ALUOP_SUB   = 2'b01,
                            ALUOP_RTYPE = 2'b10,
                            ALUOP_LUI   = 2'b11
                            } alu_op_t;
    
endpackage
