module uart_rx_top #(parameter CLK_FREQ=100_000_000,parameter BAUD_RATE=19200)(
input logic clk,rst,rx_serial_in,fifo_rd_en,
output logic [7:0]fifo_data_out,
output logic fifo_empty,fifo_full,rx_done,error_flag);
logic rx_done_wire;
logic [7:0]rx_data_wire;
uart_rx #(.CLK_FREQ(CLK_FREQ),.BAUD_RATE(BAUD_RATE)) uart_rx_inst(.clk(clk),.rst(rst),.rx_serial_in(rx_serial_in),.rx_done(rx_done_wire),.error_flag(error_flag),.rx_data_out(rx_data_wire));
fifo #(.DATA_WIDTH(8),.DEPTH_BITS(4)) fifo_inst(.clk(clk),.rst(rst),.wr_en(rx_done_wire & ~fifo_full),.data_in(rx_data_wire),.rd_en(fifo_rd_en),.data_out(fifo_data_out),.full(fifo_full),.empty(fifo_empty));
assign rx_done=rx_done_wire;
endmodule