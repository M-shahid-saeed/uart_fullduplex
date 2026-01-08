module uart_rx #(parameter CLK_FREQ=100_000_000,parameter BAUD_RATE=19200,parameter OVERSAMPLE_RATE=16)(
input logic clk,rst,rx_serial_in,
output logic rx_done,error_flag,
output logic [7:0]rx_data_out);
localparam BAUD_PERIOD_TICKS=CLK_FREQ/BAUD_RATE;
localparam OVERSAMPLE_TICK_CNT=BAUD_PERIOD_TICKS/OVERSAMPLE_RATE;
localparam MID_SAMPLE=OVERSAMPLE_RATE/2;
logic [$clog2(OVERSAMPLE_TICK_CNT)-1:0]tick_cnt;
logic [$clog2(OVERSAMPLE_RATE)-1:0]sample_cnt;
logic [3:0]bit_cnt;
logic [7:0]data_shift_reg;
logic sample_now;
logic [1:0]state;
localparam [1:0]IDLE=0,START_BIT=1,RECEIVE_DATA=2,STOP_BIT=3;
always_ff@(posedge clk or posedge rst) begin
if(rst)begin
state<=IDLE;
tick_cnt<=0;
sample_cnt<=0;
bit_cnt<=0;
rx_done<=0;
error_flag<=0;
rx_data_out<=0;
sample_now<=0;
end
else begin
rx_done<=0;
sample_now<=0;
if(state!=IDLE)begin
if(tick_cnt==OVERSAMPLE_TICK_CNT-1)begin
tick_cnt<=0;
sample_now<=1;
end
else
tick_cnt<=tick_cnt+1;
end
else
tick_cnt<=0;
case(state)
IDLE:begin
error_flag<=0;
if(rx_serial_in==0)begin
state<=START_BIT;
sample_cnt<=0;
tick_cnt<=0;
end
end
START_BIT:begin
if(sample_now)begin
sample_cnt<=sample_cnt+1;
if(sample_cnt==MID_SAMPLE)begin
if(rx_serial_in==0)begin
state<=RECEIVE_DATA;
bit_cnt<=0;
sample_cnt<=0;
end
else
state<=IDLE;
end
end
end
RECEIVE_DATA:begin
if(sample_now)begin
if(sample_cnt==MID_SAMPLE)
data_shift_reg<={rx_serial_in,data_shift_reg[7:1]};
if(sample_cnt==OVERSAMPLE_RATE-1)begin
sample_cnt<=0;
bit_cnt<=bit_cnt+1;
if(bit_cnt==7)
state<=STOP_BIT;
end
else
sample_cnt<=sample_cnt+1;
end
end
STOP_BIT:begin
if(sample_now)begin
if(sample_cnt==MID_SAMPLE)begin
if(rx_serial_in==1)begin
rx_data_out<=data_shift_reg;
rx_done<=1;
error_flag<=0;
end
else
error_flag<=1;
end
if(sample_cnt==OVERSAMPLE_RATE-1)
state<=IDLE;
else
sample_cnt<=sample_cnt+1;
end
end
endcase
end
end
endmodule