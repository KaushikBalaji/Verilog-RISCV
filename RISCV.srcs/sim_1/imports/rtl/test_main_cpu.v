`timescale 1ns/1ps

module test_main_cpu;

    reg clk;
    reg reset;

    main_cpu DUT (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #20 reset = 0;

        repeat (200) begin
            #10;

            // HALT detection
            if (DUT.instr == 32'h0000006f) begin
                $display("\n================ HALT ================");
                $display("HALT encountered at PC=%h", DUT.pc_out);
                $finish;
            end

            // ==== DEBUG OUTPUT BLOCK ====
            $display("\nT=%0t", $time);
            $display("---------------------------------------------------");
            $display(" PC          = %08h", DUT.pc_out);
            $display(" Instr       = %08h", DUT.instr);
            $display(" Opcode      = %02h", DUT.opcode);
            $display(" rd          = %0d",  DUT.rd);
            $display(" rs1         = %0d",  DUT.rs1);
            $display(" rs2         = %0d",  DUT.rs2);
            $display(" imm         = %08h", DUT.imm);
            $display("");
            $display(" rs1_data    = %08h", DUT.rs1_data);
            $display(" rs2_data    = %08h", DUT.rs2_data);
            $display("");
            $display(" ALU Result  = %08h", DUT.alu_result);
            $display(" mem_read    = %b",   DUT.mem_read);
            $display(" mem_write   = %b",   DUT.mem_write);
            $display(" mem_data    = %08h", DUT.mem_data_out);
            $display("");
            $display(" branch_taken   = %b",   DUT.is_branch_taken);
            $display(" branch_target  = %08h", DUT.branch_target);
            $display("");
            $display(" PC+4           = %08h", DUT.pc_plus_4);
            $display(" wb_sel         = %02b", DUT.wb_sel);
            $display(" wb_data        = %08h", DUT.wb_data);
            $display(" reg_write      = %b",   DUT.reg_write);
            $display("---------------------------------------------------");
        end

        $display("======== Simulation timeout ========");
        $finish;
    end

endmodule
