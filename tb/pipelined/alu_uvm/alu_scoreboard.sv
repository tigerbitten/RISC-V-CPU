import riscv_pkg::*;
import uvm_pkg::*;
import alu_ref_model_pkg::*;
`include "uvm_macros.svh"

class alu_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(alu_scoreboard)

    uvm_analysis_imp #(alu_seq_item, alu_scoreboard) item_export;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        item_export = new("item_export", this);
    endfunction

    function void write(alu_seq_item item);
        alu_expected_t exp;
        bit            flags_matter;

        exp = alu_ref_model(item.a, item.b, item.alu_control);
        flags_matter = (item.alu_control == ALU_ADD)  ||
                       (item.alu_control == ALU_SUB)  ||
                       (item.alu_control == ALU_SLT)  ||
                       (item.alu_control == ALU_SLTU);

        if (item.result != exp.result)
            `uvm_error("MISMATCH", $sformatf(
                "op=%s a=%0h b=%0h : result = %0h, expected %0h",
                item.alu_control.name(), item.a, item.b, item.result, exp.result))

        if (item.zero != exp.zero)
            `uvm_error("MISMATCH", $sformatf(
                "op=%s a=%0h b=%0h : zero = %0b, expected %0b",
                item.alu_control.name(), item.a, item.b, item.zero, exp.zero))

        if (flags_matter) begin
            if (item.negative != exp.negative)
                `uvm_error("MISMATCH", $sformatf(
                    "op=%s a=%0h b=%0h : negative = %0b, expected %0b",
                    item.alu_control.name(), item.a, item.b, item.negative, exp.negative))

            if (item.overflow != exp.overflow)
                `uvm_error("MISMATCH", $sformatf(
                    "op=%s a=%0h b=%0h : overflow = %0b, expected %0b",
                    item.alu_control.name(), item.a, item.b, item.overflow, exp.overflow))

            if (item.carry != exp.carry)
                `uvm_error("MISMATCH", $sformatf(
                    "op=%s a=%0h b=%0h : carry = %0b, expected %0b",
                    item.alu_control.name(), item.a, item.b, item.carry, exp.carry))
        end
    endfunction
endclass
