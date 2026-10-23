`timescale 1ns / 1ps

module main_controller_tb;
    reg clk = 0;
    reg reset = 1;
    reg [2:0] btn = 0;
    wire [13:0] seg_data;
    wire [15:0] led;
    wire dot_blink, animation_active;
    wire [3:0] animation_step;
    integer errors = 0;
    reg [1023:0] vcd_path;

    always #5 clk = ~clk;

    main_controller #(.CLK_FREQ(10), .IDLE_SECONDS(5)) dut (
        .clk(clk), .reset(reset), .btn(btn), .sw(8'd0),
        .seg_data(seg_data), .led(led), .dot_blink(dot_blink),
        .animation_active(animation_active), .animation_step(animation_step)
    );

    initial begin
        if (!$value$plusargs("VCD=%s", vcd_path))
            vcd_path = "stopwatch_timing.vcd";
        $dumpfile(vcd_path);
        $dumpvars(0, main_controller_tb);
        $monitor("t=%0t reset=%b btn=%b mode=%b run=%b time=%0d dot=%b anim=%b step=%0d",
                 $time, reset, btn, led[0], led[1], seg_data, dot_blink,
                 animation_active, animation_step);
    end

    task check;
        input condition;
        input [255:0] message;
        begin
            if (!condition) begin
                errors = errors + 1;
                $display("FAIL t=%0t: %0s", $time, message);
            end
        end
    endtask

    task press_button;
        input integer index;
        begin
            @(negedge clk) btn[index] = 1'b1;
            @(negedge clk) btn[index] = 1'b0;
            @(posedge clk) #1;
        end
    endtask

    initial begin
        #12 reset = 0;
        repeat (10) @(posedge clk);
        #1 check(seg_data == 14'd1 && dot_blink == 1'b1,
                 "clock did not advance and blink after one second");

        press_button(0);
        check(led[0] && seg_data == 14'd0, "btnL did not enter stopwatch mode");
        repeat (8) @(posedge clk);
        #1 check(seg_data == 14'd1, "stopwatch did not advance");

        press_button(2);
        repeat (50) @(posedge clk);
        #1 check(!led[1] && seg_data == 14'd1 && animation_active && animation_step == 0,
                 "pause timing did not reach animation step 0 after five seconds");

        press_button(2);
        #1 check(led[1] && !animation_active, "btnR did not stop animation and resume");
        repeat (6) @(posedge clk);
        #1 check(seg_data == 14'd2, "resumed stopwatch did not advance");

        press_button(1);
        check(seg_data == 14'd0, "btnC did not clear stopwatch");

        if (errors == 0)
            $display("PASS: timing chart checks completed with 0 errors.");
        else
            $display("FAIL: timing chart checks completed with %0d errors.", errors);
        $finish;
    end
endmodule
