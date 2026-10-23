`timescale 1ns / 1ps

module top(
    input clk,
    input [2:0] btn,
    input reset,
    input [1:0] sw,
    
    output [7:0] seg,
    output [3:0] an,
    output pwm_out,
    output pwm_out_led,
    output [1:0] in1_in2

    
    );

    wire [2:0] w_clean_btn;
    wire w_tick;
    wire w_duty_cycle;
    
    
    btn_debouncer   u_btn_debounce(
        .clk(clk),
        .reset(reset),
        .noisy_btn(btn),
        .clean_btn(w_clean_btn)
        
    );
    
    pwm_duty_control u_pwm_duty_control(
    .clk(clk),
    .reset(reset),
    .clean_btn(w_clean_btn),
    .duty_cycle(w_duty_cycle), // FND에 duty 출력 표시  0~9
    .pwm_out(pwm_out), 
    .pwm_out_led(pwm_out_led)
    );


    fnd_controller u_fnd_controller(
    .clk(clk),
    .reset(reset), // reset : sw15 
    .tick(w_tick), 
    .in_data({10'b0,w_duty_cycle}), // 결합 연산자로 합쳐서 넘긴다.
    .motor_direction(sw),
    .an(an),
    .seg(seg)
    );

    tick_generator u_tick_generator(
    .clk(clk),
    .reset(reset),
    .tick(w_tick)
    );


    assign in1_in2= sw; 


endmodule
