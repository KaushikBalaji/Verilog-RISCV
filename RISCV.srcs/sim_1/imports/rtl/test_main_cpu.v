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

        // Run for N cycles
        repeat(200) begin
            #10;

            // HALT detection
            if (DUT.instr == 32'h0000006f) begin
                $display("HALT at PC=%h", DUT.pc_out);
                $finish;
            end

            $display("PC=%08h Instr=%08h ALU=%08h mem=%b",
                DUT.pc_out, DUT.instr, DUT.alu_result, DUT.mem_read);

        end

        $display("Simulation ended.");
        $finish;
    end

endmodule
