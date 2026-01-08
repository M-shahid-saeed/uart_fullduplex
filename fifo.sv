module fifo #(parameter DATA_WIDTH=8,parameter DEPTH_BITS=4)(
input logic clk,rst,wr_en,rd_en,
input logic [DATA_WIDTH-1:0]data_in,
output logic [DATA_WIDTH-1:0]data_out,
output logic full,empty);
localparam DEPTH=1<<DEPTH_BITS;
logic [DATA_WIDTH-1:0]mem[0:DEPTH-1];
logic [DEPTH_BITS-1:0]wr_ptr,rd_ptr;
logic [DEPTH_BITS:0]count;
assign empty=(count==0);
assign full=(count==DEPTH);
always_ff@(posedge clk or posedge rst) begin
if(rst)begin
wr_ptr<=0;
rd_ptr<=0;
count<=0;
data_out<=0;
end
else begin
if(wr_en && !full)begin
mem[wr_ptr]<=data_in;
wr_ptr<=wr_ptr+1;
end
if(rd_en && !empty)begin
data_out<=mem[rd_ptr];
rd_ptr<=rd_ptr+1;
end
if((wr_en && !full) && (rd_en && !empty))begin
count<=count;
end
else if(wr_en && !full)begin
count<=count+1;
end
else if(rd_en && !empty)begin
count<=count-1;
end
end
end
endmodule