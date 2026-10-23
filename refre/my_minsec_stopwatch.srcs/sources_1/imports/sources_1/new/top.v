`timescale 1ns / 1ps

module top(
    input clk,
    input [2:0] btn,
    input reset,
    input [7:0] sw,
    
    output [7:0] seg,
    output [3:0] an,
    output [15:0] led
    );

    wire [2:0] w_clean_btn;
    wire [13:0] w_seg_data; // FND에 max 9999의 bin값 표시
    wire w_tick;
    wire w_dot_blink, w_animation_active;
    wire [3:0] w_animation_step;
    
    btn_debouncer   u_btn_debounce(
        .clk(clk),
        .reset(reset),
        .noisy_btn(btn),
        .clean_btn(w_clean_btn)
        
    );

    main_controller u_main_controller(
    .clk(clk),
    .reset(reset), // reset : sw15 
    .btn(w_clean_btn), 
    .sw(sw),
    .seg_data(w_seg_data),
    .led(led),
    .dot_blink(w_dot_blink),
    .animation_active(w_animation_active),
    .animation_step(w_animation_step)
    );

    fnd_controller u_fnd_controller(
    .clk(clk),
    .reset(reset), // reset : sw15 
    .tick(w_tick), 
    .in_data(w_seg_data),
    .dot_blink(w_dot_blink),
    .animation_active(w_animation_active),
    .animation_step(w_animation_step),
    .an(an),
    .seg(seg)
    );

    tick_generator u_tick_generator(
    .clk(clk),
    .reset(reset),
    .tick(w_tick)
    );


endmodule
