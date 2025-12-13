`timescale 1ns/1ps

module test_main_cpu;

    reg clk;
    reg reset;

    main_cpu DUT (.clk(clk), .reset(reset));

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset
    initial begin
        reset = 1;
        #20 reset = 0;

        // Run for max 300 cycles
        repeat (300) begin
            #10;

            // HALT recognition:
            // HALT is detected when the MEM/WB stage instruction == 0x0000006F
            if (DUT.MEM_WB_inst.mem_data_out === 32'h0000006f ||
                DUT.IF_ID_instr === 32'h0000006f) begin

                $display("\n====================== HALT ======================");
                $display("HALT encountered. PC = %h", DUT.pc_out);
                $finish;
            end

            // ----------------------------------------------------------
            // Debug Dump of Pipeline State
            // ----------------------------------------------------------
            $display("\n==================================================");
            $display(" Cycle @ T=%0t", $time);
            $display("==================================================");

            // IF Stage
            $display(" IF:   pc_out      = %08h", DUT.pc_out);
            $display("       instr       = %08h", DUT.instr);

            // IF/ID
            $display(" IF/ID:");
            $display("       pc          = %08h", DUT.IF_ID_pc);
            $display("       instr       = %08h", DUT.IF_ID_instr);

            // ID Stage
            $display(" ID:");
            $display("       rs1         = %0d",   DUT.ID_rs1);
            $display("       rs2         = %0d",   DUT.ID_rs2);
            $display("       rd          = %0d",   DUT.ID_rd);
            $display("       imm         = %08h",  DUT.ID_imm);
            $display("       rs1_data    = %08h",  DUT.ID_rs1_data);
            $display("       rs2_data    = %08h",  DUT.ID_rs2_data);

            // ID/EX
            $display(" ID/EX:");
            $display("       pc          = %08h", DUT.ID_EX_pc);
            $display("       rs1_data    = %08h", DUT.ID_EX_rs1);
            $display("       rs2_data    = %08h", DUT.ID_EX_rs2);
            $display("       imm         = %08h", DUT.ID_EX_imm);
            $display("       rd          = %0d",  DUT.ID_EX_rd);

            // EX Stage
            $display(" EX:");
            $display("       ALU result  = %08h", DUT.EX_alu_result);
            $display("       branch_taken= %b",   DUT.EX_branch_taken);
            $display("       target      = %08h", DUT.EX_branch_target);

            // EX/MEM
            $display(" EX/MEM:");
            $display("       alu         = %08h", DUT.EX_MEM_alu);
            $display("       rs2_data    = %08h", DUT.EX_MEM_rs2);
            $display("       mem_read    = %b",   DUT.EX_MEM_mem_read);
            $display("       mem_write   = %b",   DUT.EX_MEM_mem_write);
            $display("       rd          = %0d",  DUT.EX_MEM_rd);

            // MEM Stage
            $display(" MEM:");
            $display("       data_out    = %08h", DUT.MEM_data_out);

            // MEM/WB
            $display(" MEM/WB:");
            $display("       alu         = %08h", DUT.MEM_WB_alu);
            $display("       mem_out     = %08h", DUT.MEM_WB_mem);
            $display("       wb_sel      = %b",   DUT.MEM_WB_wb_sel);

            // WB Stage
            $display(" WB:");
            $display("       wb_data     = %08h", DUT.WB_data);
            $display("       wb_rd       = %0d",  DUT.WB_rd);
            $display("       wb_write    = %b",   DUT.WB_reg_write);

            $display("==================================================");
        end

        $display("============= SIMULATION TIMEOUT =============");
        $finish;
    end

endmodule
