import riscv_pkg::*;
import alu_ref_model_pkg::*;

module alu_ref_model_check_tb;
    integer errors = 0;

    task check(input string        name,
               input alu_expected_t got,
               input logic [31:0]  exp_result,
               input logic         exp_zero,
               input logic         exp_negative,
               input logic         exp_overflow,
               input logic         exp_carry);
        if (got.result != exp_result) begin
            $display("FAIL %s: result = %h, expected %h", name, got.result, exp_result);
            errors++;
        end
        if (got.zero != exp_zero) begin
            $display("FAIL %s: zero = %b, expected %b", name, got.zero, exp_zero);
            errors++;
        end
        if (got.negative != exp_negative) begin
            $display("FAIL %s: negative = %b, expected %b", name, got.negative, exp_negative);
            errors++;
        end
        if (got.overflow != exp_overflow) begin
            $display("FAIL %s: overflow = %b, expected %b", name, got.overflow, exp_overflow);
            errors++;
        end
        if (got.carry != exp_carry) begin
            $display("FAIL %s: carry = %b, expected %b", name, got.carry, exp_carry);
            errors++;
        end
    endtask

    initial begin
        // ALU_ADD, no overflow: 5 + 7 = 12
        check("ADD basic", alu_ref_model(32'd5, 32'd7, ALU_ADD),
              32'd12, 1'b0, 1'b0, 1'b0, 1'b0);

        // ALU_ADD, signed overflow: MAX_INT + 1 -> negative, overflow, no carry
        check("ADD overflow", alu_ref_model(32'h7FFFFFFF, 32'd1, ALU_ADD),
              32'h80000000, 1'b0, 1'b1, 1'b1, 1'b0);

        // ALU_SUB, no borrow: 10 - 3 = 7, carry = 1 (no borrow)
        check("SUB basic", alu_ref_model(32'd10, 32'd3, ALU_SUB),
              32'd7, 1'b0, 1'b0, 1'b0, 1'b1);

        // ALU_SUB, borrow: 3 - 10 = -7, carry = 0 (borrow occurred)
        check("SUB borrow", alu_ref_model(32'd3, 32'd10, ALU_SUB),
              -32'd7, 1'b0, 1'b1, 1'b0, 1'b0);

        // ALU_AND / OR / XOR
        check("AND", alu_ref_model(32'hF0F0F0F0, 32'h0FF00FF0, ALU_AND),
              32'h00F000F0, 1'b0, 1'bx, 1'bx, 1'bx);
        check("OR", alu_ref_model(32'hF0F0F0F0, 32'h0FF00FF0, ALU_OR),
              32'hFFF0FFF0, 1'b0, 1'bx, 1'bx, 1'bx);
        check("XOR", alu_ref_model(32'hFFFF0000, 32'h00FFFF00, ALU_XOR),
              32'hFF00FF00, 1'b0, 1'bx, 1'bx, 1'bx);

        // ALU_SLL / SRL / SRA
        check("SLL", alu_ref_model(32'h00000001, 32'd4, ALU_SLL),
              32'h00000010, 1'b0, 1'bx, 1'bx, 1'bx);
        check("SRL", alu_ref_model(32'h80000000, 32'd4, ALU_SRL),
              32'h08000000, 1'b0, 1'bx, 1'bx, 1'bx);
        check("SRA", alu_ref_model(32'h80000000, 32'd4, ALU_SRA),
              32'hF8000000, 1'b0, 1'bx, 1'bx, 1'bx);

        // ALU_LUI passes b through
        check("LUI", alu_ref_model(32'hDEADBEEF, 32'h12345000, ALU_LUI),
              32'h12345000, 1'b0, 1'bx, 1'bx, 1'bx);

        // ALU_SLT: signed -1 < 1 -> true
        check("SLT true", alu_ref_model(-32'd1, 32'd1, ALU_SLT),
              32'd1, 1'b0, 1'bx, 1'bx, 1'bx);

        // ALU_SLT: signed 1 < -1 -> false
        check("SLT false", alu_ref_model(32'd1, -32'd1, ALU_SLT),
              32'd0, 1'b1, 1'bx, 1'bx, 1'bx);

        // ALU_SLTU: unsigned 0xFFFFFFFF < 1 -> false (0xFFFFFFFF is huge unsigned)
        check("SLTU false", alu_ref_model(32'hFFFFFFFF, 32'd1, ALU_SLTU),
              32'd0, 1'b1, 1'bx, 1'bx, 1'bx);

        // ALU_SLTU: unsigned 1 < 0xFFFFFFFF -> true
        check("SLTU true", alu_ref_model(32'd1, 32'hFFFFFFFF, ALU_SLTU),
              32'd1, 1'b0, 1'bx, 1'bx, 1'bx);

        if (errors == 0)
            $display("ALL CHECKS PASSED");
        else
            $display("%0d CHECK(S) FAILED", errors);

        $finish;
    end
endmodule
