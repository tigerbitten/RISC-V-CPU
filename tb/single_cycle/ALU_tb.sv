import riscv_pkg::*;

module ALU_tb();
    reg [31:0] a, b, result;
    alu_control_t  alu_control;
    reg        zero, negative, overflow, carry;

    ALU dut (.a           (a),
             .b           (b),
             .alu_control (alu_control),
             .result      (result),
             .zero        (zero),
             .negative    (negative),
             .overflow    (overflow),
             .carry       (carry));
    
    task check (input [31:0] test_a,
                input [31:0] test_b,
                input        alu_control_t test_control,
                input [31:0] expected_res,
                input        expected_z,
                input        expected_negative,
                input        expected_overflow,
                input        expected_carry);
        begin
            a = test_a;
            b = test_b;
            alu_control = test_control;

            #1;

            if (result != expected_res || expected_z != zero || expected_negative != negative || expected_overflow != overflow || carry != expected_carry) begin
                $display("FAIL: a=%h b=%h alu_control=%s zero=%h negative=%h overflow=%h carry=%h result=%h expected=%h expected_z=%h expected_neg=%h expected_overflow=%h expected_carry=%h",
                         a, b, alu_control.name(), zero, negative, overflow, carry, result, expected_res, expected_z, expected_negative, expected_overflow, expected_carry);
            end else begin
                $display("PASS: alu_control=%s", alu_control.name());
            end
        end
    endtask

    initial begin
        //using x as expected neg and expected overflow for operations where it is irrelevant
        // ADD
        check(32'd3, 32'd10, ALU_ADD, 32'd13, 1'd0, 1'b0, 1'b0, 1'bx);
        check(32'hFFFFFFFF, 32'd1, ALU_ADD, 32'd0, 1'd1, 1'b0, 1'b0, 1'bx);
        check(32'h80000000, 32'hFFFFFFFF, ALU_ADD, 32'dx, 1'b0, 1'bx, 1'b1, 1'bx); //test neg signed overflow
        check(32'h7FFFFFFF, 32'h7FFFFFFF, ALU_ADD, 32'dx, 1'b0, 1'bx, 1'b1, 1'bx); //test pos signed overflow
        check(32'hF0000000, 32'h00000011, ALU_ADD, 32'hF0000011, 1'b0, 1'b1, 1'b0, 1'bx); //test neg flag

        // SUB
        check(32'd140, 32'd21, ALU_SUB, 32'd119, 1'd0, 1'b0, 1'b0, 1'b0);
        check(32'd14,  32'd15, ALU_SUB, 32'hFFFF_FFFF, 1'd0, 1'b1, 1'b0, 1'b1);
        check(32'h80000000, 32'h7FFFFFFF, ALU_SUB, 32'dx, 1'b0, 1'bx, 1'b1, 1'b0); //test neg signed overflow
        check(32'h7FFFFFFF, 32'hF0000000, ALU_SUB, 32'dx, 1'b0, 1'bx, 1'b1, 1'b1); //test pos signed overflow
        check(32'hF000F000, 32'h00000011, ALU_SUB, 32'hF000EFEF, 1'b0, 1'b1, 1'b0, 1'b0); //test neg flag

        // XOR
        check(32'hFFFF_FFFF,  32'd0, ALU_XOR, 32'hFFFF_FFFF, 1'd0, 1'bx, 1'bx, 1'bx);

        // AND
        check(32'hFFFF_0000, 32'h0F0F_F0F0, ALU_AND, 32'h0F0F_0000, 1'd0, 1'bx, 1'bx, 1'bx);
        check(32'hFFFF_FFFF, 32'h0000_0000, ALU_AND, 32'h0000_0000, 1'd1, 1'bx, 1'bx, 1'bx);

        // OR
        check(32'hFFFF_0000, 32'h0F0F_F0F0, ALU_OR, 32'hFFFF_F0F0, 1'd0, 1'bx, 1'bx, 1'bx);
        check(32'hFFFF_FFFF, 32'h0000_0000, ALU_OR, 32'hFFFF_FFFF, 1'd0, 1'bx, 1'bx, 1'bx);

        // SLL
        check(32'hFFFF_0000, 32'd4, ALU_SLL, 32'hFFF0_0000, 1'd0, 1'bx, 1'bx, 1'bx);

        // SRL
        check(32'hFFFF_0000, 32'd4, ALU_SRL, 32'h0FFF_F000, 1'd0, 1'bx, 1'bx, 1'bx);

        // SLT
        check(32'hFFFF_0000, 32'd0, ALU_SLT, 32'd1, 1'd0, 1'bx, 1'bx, 1'bx);
        check(32'h0FFF_0000, 32'd0, ALU_SLT, 32'd0, 1'd1, 1'bx, 1'bx, 1'bx);

        // SLTU
        check(32'hFFFF_0000, 32'd0, ALU_SLTU, 32'd0, 1'd1, 1'bx, 1'bx, 1'bx);
        check(32'hFFFF_0000, 32'hFFFF_0001, ALU_SLTU, 32'd1, 1'd0, 1'bx, 1'bx, 1'bx);

        // SRA
        check(32'h0FFF_F000, 32'd4, ALU_SRA, 32'h00FF_FF00, 1'd0, 1'bx, 1'bx, 1'bx); // interprets as unsigned
        check(32'hFFFF_0000, 32'd4, ALU_SRA, 32'hFFFF_F000, 1'd0, 1'bx, 1'bx, 1'bx); // should sign extend

        // LUI
        check(32'd0, 32'h0000_0000, ALU_LUI, 32'h0000_0000, 1'd1, 1'bx, 1'bx, 1'bx);

        $finish;
    end
endmodule
