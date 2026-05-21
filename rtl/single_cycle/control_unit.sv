module control_unit(input [6:0]  opcode,
                    output [1:0] alu_op,
                    output       alu_src,
                    output       branch_ctrl,
                    output       jump,
                    output       mem_read,
                    output       mem_write,
                    output [1:0] mem_to_reg,
                    output       reg_write);

    always_comb begin
        case (opcode)
          7'b1100011 : begin //B-Type
              alu_op      = 2'b01;
              alu_src     = 1'b0;
              branch_ctrl = 1'b1;
              jump        = 1'b0;
              mem_read    = 1'b0;
              mem_write   = 1'b0;
              mem_to_reg  = 2'b00;
              reg_write   = 1'b0;
          end
          7'b0110011 : begin //R-Type
              alu_op      = 2'b10;
              alu_src     = 1'b0;
              branch_ctrl = 1'b0;
              jump        = 1'b0;
              mem_read    = 1'b0;
              mem_write   = 1'b0;
              mem_to_reg  = 2'b00;
              reg_write   = 1'b1;
          end
          7'b0010011 : begin //I-Type ALU immediate instructions
              alu_op      = 2'b10;
              alu_src     = 1'b1;
              branch_ctrl = 1'b0;
              jump        = 1'b0;
              mem_read    = 1'b0;
              mem_write   = 1'b0;
              mem_to_reg  = 2'b00;
              reg_write   = 1'b1;
          end
          7'b0000011 : begin //I-Type load instructions
              alu_op      = 2'b00;
              alu_src     = 1'b1;
              branch_ctrl = 1'b0;
              jump        = 1'b0;
              mem_read    = 1'b1;
              mem_write   = 1'b0;
              mem_to_reg  = 2'b01;
              reg_write   = 1'b1;
          end
          7'b1100111 : begin //I-Type JALR instruction
              alu_op      = 2'b00;
              alu_src     = 1'b1;
              branch_ctrl = 1'b0;
              jump        = 1'b1;
              mem_read    = 1'b0;
              mem_write   = 1'b0;
              mem_to_reg  = 2'b10; //special input -- means we write PC+4 to rd register
              reg_write   = 1'b1;
          end
          7'b0100011 : begin //S-Type instructions
              alu_op      = 2'b00;
              alu_src     = 1'b1;
              branch_ctrl = 1'b0;
              jump        = 1'b0;
              mem_read    = 1'b0;
              mem_write   = 1'b1;
              mem_to_reg  = 2'b00;
              reg_write   = 1'b0;
          end
          7'b1101111 : begin //J-Type instructions (JAL only for now)
              alu_op      = 2'b00;
              alu_src     = 1'b0;
              branch_ctrl = 1'b0;
              jump        = 1'b1;
              mem_read    = 1'b0;
              mem_write   = 1'b0;
              mem_to_reg  = 2'b10;
              reg_write   = 1'b1;
          end
        endcase
    end
endmodule
                    
