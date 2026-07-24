package alu_ref_model_pkg;
    import riscv_pkg::*;

    typedef struct {
        logic [31:0] result;
        logic zero;
        logic carry;
        logic overflow;
        logic negative;
    } alu_expected_t;

    function automatic alu_expected_t alu_ref_model(input logic [31:0]  a,
                                                    input logic [31:0]  b,
                                                    input alu_control_t alu_control);
        alu_expected_t out;
        logic [32:0]   temp;

        case (alu_control)
          ALU_ADD : begin
              temp         = {1'b0, a} + {1'b0, b};
              out.result   = temp[31:0];
              out.carry    = temp[32];
              out.zero     = (out.result == 0);
              out.negative = out.result[31];
              out.overflow = (a[31] == b[31]) && (out.result[31] != a[31]);
          end
          ALU_SUB : begin
              temp         = {1'b0, a} - {1'b0, b};
              out.result   = a - b;
              out.carry    = !temp[32];
              out.zero     = (out.result == 0);
              out.negative = out.result[31];
              out.overflow = (a[31] != b[31]) && (out.result[31] != a[31]);
          end

          ALU_AND : begin
              temp         = {1'b0, a} + {1'b0, b};
              out.result   = a & b;
              out.carry    = temp[32];
              out.negative = temp[31];
              out.overflow = (a[31] == b[31]) && (temp[31] != a[31]);
              out.zero     = (out.result == 0);
          end

          ALU_OR : begin
              temp         = {1'b0, a} + {1'b0, b};
              out.result   = a | b;
              out.carry    = temp[32];
              out.negative = temp[31];
              out.overflow = (a[31] == b[31]) && (temp[31] != a[31]);
              out.zero     = (out.result == 0);
          end

          ALU_XOR : begin
              temp         = {1'b0, a} + {1'b0, b};
              out.result   = a ^ b;
              out.carry    = temp[32];
              out.negative = temp[31];
              out.overflow = (a[31] == b[31]) && (temp[31] != a[31]);
              out.zero     = (out.result == 0);
          end

          ALU_SLL : begin
              temp         = {1'b0, a} + {1'b0, b};
              out.result   = a << b[4:0];
              out.carry    = temp[32];
              out.negative = temp[31];
              out.overflow = (a[31] == b[31]) && (temp[31] != a[31]);
              out.zero     = (out.result == 0);
          end

          ALU_SRL : begin
              temp         = {1'b0, a} + {1'b0, b};
              out.result   = a >> b[4:0];
              out.carry    = temp[32];
              out.negative = temp[31];
              out.overflow = (a[31] == b[31]) && (temp[31] != a[31]);
              out.zero     = (out.result == 0);
          end

          ALU_SRA : begin
              temp         = {1'b0, a} + {1'b0, b};
              out.result   = $signed(a) >>> b[4:0];
              out.carry    = temp[32];
              out.negative = temp[31];
              out.overflow = (a[31] == b[31]) && (temp[31] != a[31]);
              out.zero     = (out.result == 0);
          end

          ALU_LUI : begin
              temp         = {1'b0, a} + {1'b0, b};
              out.result   = b;
              out.carry    = temp[32];
              out.negative = temp[31];
              out.overflow = (a[31] == b[31]) && (temp[31] != a[31]);
              out.zero     = (out.result == 0);
          end

          ALU_SLT : begin
              temp         = {1'b0, a} - {1'b0, b};
              out.carry    = !temp[32];
              out.negative = temp[31];
              out.overflow = (a[31] != b[31]) && (temp[31] != a[31]);
              out.result   = {31'b0, out.negative ^ out.overflow};
              out.zero     = (out.result == 0);
          end

          ALU_SLTU : begin
              temp         = {1'b0, a} - {1'b0, b};
              out.carry    = !temp[32];
              out.negative = temp[31];
              out.overflow = (a[31] != b[31]) && (temp[31] != a[31]);
              out.result   = {31'b0, !out.carry};
              out.zero     = (out.result == 0);
          end
        endcase

        return out;
    endfunction
endpackage
