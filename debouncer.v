module debouncer #(
    parameter integer STABLE_CYCLES = 16   // cycles the input must hold steady
)(
    input  wire clk,
    input  wire btn_raw,     // asynchronous, from the outside world
    output reg  btn_out = 1'b0
);
    reg sync_0 = 1'b0;
    reg sync_1 = 1'b0;
    reg [$clog2(STABLE_CYCLES):0] count = 0;

    // Stage 1: synchronize the asynchronous input to our clock
    always @(posedge clk) begin
        sync_0 <= btn_raw;
        sync_1 <= sync_0;
    end

    // Stage 2: accept a new level only after it has been stable for STABLE_CYCLES
    always @(posedge clk) begin
        if (sync_1 == btn_out) begin
            count <= 0;                          // no change pending, reset the timer
        end else if (count == STABLE_CYCLES - 1) begin
            btn_out <= sync_1;                   // held long enough, accept it
            count   <= 0;
        end else begin
            count <= count + 1;                  // different from output, keep counting
        end
    end
endmodule
