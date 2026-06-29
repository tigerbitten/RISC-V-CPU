import riscv_pkg::*;

module forwarding_unit(input [4:0]             ex_rs1_addr,
                       input [4:0]             ex_rs2_addr,
                       input [4:0]             mem_rd_addr,
                       input                   mem_reg_write,
                       input [4:0]             wb_rd_addr,
                       input                   wb_reg_write,
                       output forward_select_t forward_a_select,
                       output forward_select_t forward_b_select);
    
    always_comb begin
        //select for A ALU input mux
        if (mem_reg_write &&
            (ex_rs1_addr == mem_rd_addr) &&
            (mem_rd_addr !=0)) begin //forward prior ALU result (mem_alu_result)
            forward_a_select = FWD_MEM;
        end else if (wb_reg_write &&
            (ex_rs1_addr == wb_rd_addr) &&
            (wb_rd_addr !=0)) begin //forward wb_rd_data (covers loads too, not just ALU)
            forward_a_select = FWD_WB;
        end else begin
            forward_a_select = FWD_NONE; //pass ex_rs1_data through
        end

        //select for B ALU input mux
        if (mem_reg_write &&
            (ex_rs2_addr == mem_rd_addr) &&
            (mem_rd_addr !=0)) begin //forward prior ALU result (mem_alu_result)
            forward_b_select = FWD_MEM;
        end else if (wb_reg_write &&
            (ex_rs2_addr == wb_rd_addr) &&
            (wb_rd_addr !=0)) begin //forward wb_rd_data (covers loads too, not just ALU)
            forward_b_select = FWD_WB;
        end else begin
            forward_b_select = FWD_NONE; //pass ex_rs2_data through
        end
    end
endmodule
    
