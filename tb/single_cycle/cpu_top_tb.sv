import riscv_pkg::*;

module cpu_top_tb;

    reg clk, reset;
    
    cpu_top dut (.clk   (clk),
                 .reset (reset));

    always begin
        clk = 0;
        #10;
        clk = 1;
        #10;
    end
    
    task tick();
        begin
            $display("PC:%d instruction:%h", dut.pc.pc_out, dut.imem.instruction);
            $display("   alu_result=%h alu_op=%b alu_ctrl=%b zero=%b", dut.alu.result, dut.ctrl_unit.alu_op, dut.alu_ctrl.alu_control, dut.zero);
            $display("       funct3=%b funct7_30=%b", dut.alu_ctrl.funct3, dut.alu_ctrl.funct7_30);
            @(posedge clk) #1;
        end
    endtask

    task check_reg(input [4:0] register_num,
                   input [31:0] expected_val);
        begin
            if (dut.reg_file.registers[register_num] !== expected_val) begin
                $display("FAIL: register=%d val=%h expected=%h", register_num, dut.reg_file.registers[register_num], expected_val);
            end
            else
                $display("PASS: register=%d val=%h", register_num, expected_val);
        end
    endtask

    task check_mem (input [31:0] addr,
                    input [31:0] expected_val,
                    input        mem_width_t width);
        begin
            reg [31:0] actual;
            
            case(width)
              MEM_WIDTH_BYTE     : actual = dut.data_mem.memory[addr];
              MEM_WIDTH_HALFWORD : actual = {dut.data_mem.memory[addr+1], dut.data_mem.memory[addr]};
              MEM_WIDTH_WORD     : actual = {dut.data_mem.memory[addr+3], dut.data_mem.memory[addr+2], dut.data_mem.memory[addr+1], dut.data_mem.memory[addr]};
            endcase

            if (actual !== expected_val) begin
                $display("FAIL: actual=%h expected=%h width=%s", actual, expected_val, width.name());
            end
            else
                $display("PASS: memory[%d]=%h width=%s", addr, actual, width.name());
        end
    endtask

    initial begin
        reset = 1;
        tick();
        tick();
        reset = 0;
        check_reg(1, 32'd0);
//---CHECKS FOR program_test_1.mem---        
        //check load immediates section
        tick();
        check_reg(1, 32'd5);
        tick();
        check_reg(2, 32'd3);
        //check R-Type arithmetic section
        tick();
        check_reg(3, 32'd8);
        tick();
        check_reg(4, 32'd2);
        tick();
        check_reg(5, 32'd1);
        tick();
        check_reg(6, 32'd7);
        tick();
        check_reg(7, 32'd6);
        tick();
        check_reg(8, 32'd1);
        tick();
        check_reg(9, 32'd1);
        //check shifts section
        tick();
        check_reg(10, 32'd20);
        tick();
        check_reg(11, 32'd10);
        tick();
        check_reg(12, 32'hFFFF_FFF8); //-8
        tick();
        check_reg(13, 32'hFFFF_FFFC); //-4
        //store and load words section
        tick();
        check_reg(14, 32'd100);
        tick();
        check_mem(32'd0, 32'd100, MEM_WIDTH_WORD);
        tick();
        check_reg(15, 32'd100);
        //store and load byte section
        tick();
        check_reg(16, 32'd65);
        tick();
        check_mem(32'd4, 32'd65, MEM_WIDTH_BYTE);
        tick();
        check_reg(17, 32'd65);
        //BEQ taken section
        tick();
        check_reg(18, 32'd0);
        tick(); //brach evaluation
        tick();
        check_reg(18, 32'd8); //should be 8
    end
endmodule
