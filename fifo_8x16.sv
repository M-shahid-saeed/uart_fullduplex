module fifo_8x16(
input logic clk,rst,trans_start,read_enable,
input logic [7:0]data_in,
output logic [7:0]dout,
output logic fifo_full,fifo_empty);
logic [7:0]mem[0:15];
logic [3:0]wr_ptr,rd_ptr;
logic [4:0]count;
assign fifo_full=(count==16);
assign fifo_empty=(count==0);
always_ff@(posedge clk or posedge rst) begin
if(rst)begin
wr_ptr<=0;
rd_ptr<=0;
count<=0;
dout<=0;
end
else begin
if(trans_start && !fifo_full)begin
mem[wr_ptr]<=data_in;
wr_ptr<=wr_ptr+1;
end
if(read_enable && !fifo_empty)begin
dout<=mem[rd_ptr];
rd_ptr<=rd_ptr+1;
end
if((trans_start && !fifo_full) && (read_enable && !fifo_empty))begin
count<=count;
end
else if(trans_start && !fifo_full)begin
count<=count+1;
end
else if(read_enable && !fifo_empty)begin
count<=count-1;
end
end
end
endmodule