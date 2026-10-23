`timescale 1ns / 1ps

module main_controller(
    input clk,
    input reset,
    input [2:0] btn,       // btn[0]: btnL, btn[1]: btnC, btn[2]: btnR
    input [7:0] sw,
    output [13:0] seg_data,
    output reg [15:0] led,
    output dot_blink,
    output animation_active,
    output [3:0] animation_step
    );

    parameter CLK_FREQ = 100_000_000;
    parameter IDLE_SECONDS = 5;

    reg [$clog2(CLK_FREQ)-1:0] r_tick_counter = 0;
    reg [5:0] r_clock_min = 0, r_clock_sec = 0;
    reg [5:0] r_stopwatch_min = 0, r_stopwatch_sec = 0;
    reg r_stopwatch_mode = 0, r_stopwatch_running = 1;
    reg [2:0] r_prev_btn = 0;
    reg r_dot_blink = 0;
    reg [$clog2(IDLE_SECONDS)-1:0] r_idle_seconds = 0;
    reg r_animation_active = 0;
    reg [3:0] r_animation_step = 0;

    wire w_second_tick = (r_tick_counter == CLK_FREQ - 1);
    wire w_btnL_press = btn[0] && !r_prev_btn[0];
    wire w_btnC_press = btn[1] && !r_prev_btn[1];
    wire w_btnR_press = btn[2] && !r_prev_btn[2];
    wire w_any_btn_press = w_btnL_press || w_btnC_press || w_btnR_press;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_tick_counter <= 0;
            r_clock_min <= 0;
            r_clock_sec <= 0;
            r_stopwatch_min <= 0;
            r_stopwatch_sec <= 0;
            r_stopwatch_mode <= 0;
            r_stopwatch_running <= 1;
            r_prev_btn <= 0;
            r_dot_blink <= 0;
            r_idle_seconds <= 0;
            r_animation_active <= 0;
            r_animation_step <= 0;
        end else begin
            r_prev_btn <= btn;

            if (w_second_tick) begin
                r_tick_counter <= 0;
                r_dot_blink <= !r_dot_blink;
                if (r_clock_sec == 59) begin
                    r_clock_sec <= 0;
                    r_clock_min <= (r_clock_min == 59) ? 0 : r_clock_min + 1;
                end else begin
                    r_clock_sec <= r_clock_sec + 1;
                end

                if (r_stopwatch_mode && r_stopwatch_running) begin
                    if (r_stopwatch_sec == 59) begin
                        r_stopwatch_sec <= 0;
                        r_stopwatch_min <= (r_stopwatch_min == 59) ? 0 : r_stopwatch_min + 1;
                    end else begin
                        r_stopwatch_sec <= r_stopwatch_sec + 1;
                    end
                end
            end else begin
                r_tick_counter <= r_tick_counter + 1;
            end

            if (w_any_btn_press) begin
                r_idle_seconds <= 0;
                r_animation_active <= 0;
                r_animation_step <= 0;
            end else if (r_stopwatch_mode && !r_stopwatch_running) begin
                if (w_second_tick) begin
                    if (r_idle_seconds == IDLE_SECONDS - 1) begin
                        r_animation_active <= 1;
                        r_animation_step <= r_animation_active ?
                                            (r_animation_step == 11 ? 0 : r_animation_step + 1) : 0;
                    end else begin
                        r_idle_seconds <= r_idle_seconds + 1;
                    end
                end
            end else begin
                r_idle_seconds <= 0;
                r_animation_active <= 0;
                r_animation_step <= 0;
            end

            if (w_btnL_press)
                r_stopwatch_mode <= !r_stopwatch_mode;

            if (w_btnC_press) begin
                r_stopwatch_min <= 0;
                r_stopwatch_sec <= 0;
            end

            if (w_btnR_press && r_stopwatch_mode)
                r_stopwatch_running <= !r_stopwatch_running;
        end
    end

    assign seg_data = r_stopwatch_mode ?
                      r_stopwatch_min * 100 + r_stopwatch_sec :
                      r_clock_min * 100 + r_clock_sec;
    assign dot_blink = !r_stopwatch_mode && r_dot_blink;
    assign animation_active = r_animation_active;
    assign animation_step = r_animation_step;

    always @(*) begin
        led = 0;
        led[0] = r_stopwatch_mode;
        led[1] = r_stopwatch_mode && r_stopwatch_running;
    end

endmodule
