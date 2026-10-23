`timescale 1ns / 1ps

// (1) 100Mhz --> 10Mhz의 주파수를 생성 
// (2) 10Mhz로 duty 조절 

module pwm_duty_control(
    input clk,
    input reset,
    input [3:0] clean_btn,

    output [3:0] duty_cycle, // FND에 duty 출력 표시  0~9
    output pwm_out, 
    output pwm_out_led
);
endmodule







