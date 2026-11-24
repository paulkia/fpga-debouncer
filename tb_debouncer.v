`timescale 1ns/1ps
module tb_debouncer;
    reg  clk = 0;
    reg  btn_raw = 0;
    wire btn_out;

    debouncer #(.STABLE_CYCLES(16)) dut (
        .clk(clk), .btn_raw(btn_raw), .btn_out(btn_out)
    );

    always #5 clk = ~clk;                        // 100 MHz, 10 ns period

    // Print every change of the debounced output with its timestamp
    always @(btn_out) $display("%0t ns: btn_out = %b", $time, btn_out);

    // Simulate a mechanical switch: 20 random glitches, then settle at 'value'
    task bounce(input value);
        integer i;
        begin
            for (i = 0; i < 20; i = i + 1) begin
                btn_raw = $random;               // random 0/1
                #(5 + ($random & 15));           // each glitch lasts 5-20 ns
            end
            btn_raw = value;
            #2000;                               // long enough to settle
        end
    endtask

    initial begin
        $dumpfile("debouncer.vcd");
        $dumpvars(0, tb_debouncer);
        #50;
        bounce(1);                               // press
        bounce(0);                               // release
        #50;
        $finish;
    end
endmodule
