module uart_tx_top #(parameter CLK_FREQ=100_000_000,parameter BAUD_RATE=19200)(
input logic clk,rst,trans_start,
input logic [7:0]data_in,
output logic tx_pin,fifo_full,transmission_complete);

logic [7:0]dout;

logic fifo_empty,read_enable;

fifo_8x16 fifo_inst(.clk(clk),.rst(rst),.data_in(data_in),.trans_start(trans_start),.read_enable(read_enable),.dout(dout),.fifo_full(fifo_full),.fifo_empty(fifo_empty));
shift_register_tx #(.CLK_FREQ(CLK_FREQ),.BAUD_RATE(BAUD_RATE)) shift_tx_inst(.clk(clk),.rst(rst),.fifo_empty(fifo_empty),.dout(dout),.read_enable(read_enable),.tx_pin(tx_pin),.transmission_complete(transmission_complete));

endmodule