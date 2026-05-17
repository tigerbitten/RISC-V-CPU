module ALU_tb();
    reg [31:0] a, b, result;
    reg [3:0]  alu_control;
    reg        zero;

    ALU dut (.a           (a),
             .b           (b),
             .alu_control (alu_control),
             .result      (result),
             .zero        (zero));
    
    task check (input [31:0] test_a,
                input [31:0] test_b,
                input [3:0]  test_control,
                input [31:0] expected_res,
                input        expected_z);
        begin
            a = test_a;
            b = test_b;
            alu_control = test_control;

            #1;

            if (result != expected_res || expected_z != zero) begin
                $display("FAIL: a=%h b=%h alu_control=%h zero=%h result=%h expected=%h expected_z=%h",
                         a, b, alu_control, zero, result, expected_res, expected_z);
            end else begin
                $display("PASS: alu_control=%h", alu_control);
            end
        end
    endtask

    initial begin
        // ADD
        check(32'd3, 32'd10, 4'b0010, 32'd13, 1'd0);
        check(32'hFFFFFFFF, 32'd1, 4'b0010, 32'd0, 1'd1);

        // SUB
        check(32'd140, 32'd21, 4'b0110, 32'd119, 1'd0);
        check(32'd14,  32'd15, 4'b0110, 32'hFFFF_FFFF, 1'd0);

        // XOR
        check(32'hFFFF_FFFF,  32'd0, 4'b0011, 32'hFFFF_FFFF, 1'd0);

        // AND
        check(32'hFFFF_0000, 32'h0F0F_F0F0, 4'b0000, 32'h0F0F_0000, 1'd0);
        check(32'hFFFF_FFFF, 32'h0000_0000, 4'b0000, 32'h0000_0000, 1'd1);

        // OR
        check(32'hFFFF_0000, 32'h0F0F_F0F0, 4'b0001, 32'hFFFF_F0F0, 1'd0);
        check(32'hFFFF_FFFF, 32'h0000_0000, 4'b0001, 32'hFFFF_FFFF, 1'd0);

        // SLL
        check(32'hFFFF_0000, 32'd4, 4'b0100, 32'hFFF0_0000, 1'd0);

        // SRL
        check(32'hFFFF_0000, 32'd4, 4'b0101, 32'h0FFF_F000, 1'd0);

        // SLT
        check(32'hFFFF_0000, 32'd0, 4'b0111, 32'd1, 1'd0);
        check(32'h0FFF_0000, 32'd0, 4'b0111, 32'd0, 1'd1);

        // SLTU
        check(32'hFFFF_0000, 32'd0, 4'b1000, 32'd0, 1'd1);
        check(32'hFFFF_0000, 32'hFFFF_0001, 4'b1000, 32'd1, 1'd0);

        // SRA
        check(32'h0FFF_F000, 32'd4, 4'b1001, 32'h00FF_FF00, 1'd0); // interprets as unsigned
        check(32'hFFFF_0000, 32'd4, 4'b1001, 32'hFFFF_F000, 1'd0); // should sign extend

        // LUI
        check(32'd0, 32'hFFFF_FFFF, 4'b1010, 32'hFFFF_F000, 1'd0);

        $finish;
    end
endmodule
