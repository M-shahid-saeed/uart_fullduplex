module uart_full_duplex_top #(
    parameter CLK_FREQ=100_000_000, 
    parameter BAUD_RATE=19200
)(
    input logic clk, rst,
    input logic tx_start_A, tx_start_B,
    input logic [7:0] data_in_A, data_in_B,
    // --- Changes Start: tx_done ports add kiye ---
    output logic tx_A, tx_B, 
    output logic rx_done_A, rx_done_B,
    output logic tx_done_A, tx_done_B, // <--- NEW PORTS
    output logic [7:0] fifo_data_A, fifo_data_B
);

    logic txA_to_rxB, txB_to_rxA;
    logic [7:0] rx_data_A_wire, rx_data_B_wire;

    // Instance A
    uart_top #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) uartA(
        .clk(clk),
        .reset(rst),
        .data_in(data_in_A),
        .tx_start(tx_start_A),
        .rx_serial_in(txB_to_rxA),
        .tx_serial_out(txA_to_rxB),
        .tx_done(tx_done_A),  // <--- CONNECTED HERE
        .rx_data(rx_data_A_wire),
        .rx_done(rx_done_A),
        .error_flag() // error_flag connect nahi tha, chhod diya
    );

    // Instance B
    uart_top #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) uartB(
        .clk(clk),
        .reset(rst),
        .data_in(data_in_B),
        .tx_start(tx_start_B),
        .rx_serial_in(txA_to_rxB),
        .tx_serial_out(txB_to_rxA),
        .tx_done(tx_done_B),  // <--- CONNECTED HERE
        .rx_data(rx_data_B_wire),
        .rx_done(rx_done_B),
        .error_flag()
    );

    assign tx_A = txA_to_rxB;
    assign tx_B = txB_to_rxA;
    
    // Note: FIFO assignments aapke original code mein missing thi
    // Maine wire se assign kar diya hai taake output mile
    assign fifo_data_A = rx_data_A_wire; 
    assign fifo_data_B = rx_data_B_wire;

endmodule