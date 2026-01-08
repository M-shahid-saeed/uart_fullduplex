module uart_top #(parameter CLK_FREQ=100_000_000,parameter BAUD_RATE=19200)(
input logic clk,reset,tx_start,rx_serial_in,
input logic [7:0]data_in,
output logic tx_serial_out,tx_done,rx_done,error_flag,
output logic [7:0]rx_data);
uart_tx_top #(.CLK_FREQ(CLK_FREQ),.BAUD_RATE(BAUD_RATE)) uart_tx_inst(.clk(clk),.rst(reset),.data_in(data_in),.trans_start(tx_start),.tx_pin(tx_serial_out),.fifo_full(),.transmission_complete(tx_done));
uart_rx_top #(.CLK_FREQ(CLK_FREQ),.BAUD_RATE(BAUD_RATE)) uart_rx_inst(.clk(clk),.rst(reset),.rx_serial_in(rx_serial_in),.fifo_rd_en(1'b0),.fifo_data_out(rx_data),.fifo_empty(),.fifo_full(),.rx_done(rx_done),.error_flag(error_flag));
endmodule