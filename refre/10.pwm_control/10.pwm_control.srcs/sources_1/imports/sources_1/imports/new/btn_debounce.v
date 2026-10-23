`timescale 1ns / 1ps

module btn_debouncer (
        input clk,
        input reset,
        input [2:0] noisy_btn,
        output [2:0] clean_btn
);


    debouncer  u_btnL_debounce(
        .clk(clk),
        .reset(reset),
        .noisy_btn(noisy_btn[0]),  // raw noist button input
        .clean_btn(clean_btn[0])
    );
    
    debouncer  u_btnC_debounce(
        .clk(clk),
        .reset(reset),
        .noisy_btn(noisy_btn[1]),  // raw noist button input
        .clean_btn(clean_btn[1])
    );
    
    debouncer  u_btnR_debounce(
        .clk(clk),
        .reset(reset),
        .noisy_btn(noisy_btn[2]),  // raw noist button input
        .clean_btn(clean_btn[2])
    );
    
endmodule






module debouncer #(parameter DEBOUNCE_LIMIT = 20'd999_999) (
    input      clk,
    input      reset,
    input      noisy_btn,  // raw noisy button input
    output reg clean_btn
);
    reg [19:0] r_count;
    reg r_btn_state=0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin   // active-high reset
            r_count <= 0;
            r_btn_state <= 0;
            clean_btn <= 0;
        end else if (noisy_btn == r_btn_state) begin  // 버튼 상태가 이전과 동일할 경우 (안정됨)
            r_count <= 0;
        end else begin
            if (r_count < DEBOUNCE_LIMIT)  // 버튼 상태가 바뀌었지만 아직 안정되지 않은 경우
                r_count <= r_count + 1;
            else begin  // 상태가 충분히 오랫동안 유지됨(10ms)
                r_btn_state <= noisy_btn;
                clean_btn <= noisy_btn;
                r_count <= 0;  // clear하면 다음 변경을 다시 감지할 수 있음
            end
        end
    end
endmodule