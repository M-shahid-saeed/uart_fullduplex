interface uart_intf(input logic clk);
    logic rst;

    // --- External Signals ---
    logic tx_start_A, tx_start_B;
    logic [7:0] data_in_A, data_in_B;
    logic tx_A, tx_B;
    logic rx_done_A, rx_done_B;
    logic [7:0] fifo_data_A, fifo_data_B;
    logic tx_done_A, tx_done_B;

    // --- INTERNAL SPY SIGNALS (Jasoosi wale signals) ---
    logic [7:0] spy_rx_data_A; 
    logic       spy_rx_valid_A; 
    
    logic [7:0] spy_rx_data_B; 
    logic       spy_rx_valid_B; 

    // --- Hierarchical Connections (UPDATED NAMES) ---
    
    // Path: tb_top -> dut -> uartA -> uart_rx_inst -> fifo_inst -> signal
    
    // Side A Internal Connections (uartA use kiya)
    assign spy_rx_data_A  = tb_top.dut.uartA.uart_rx_inst.fifo_inst.data_in;
    assign spy_rx_valid_A = tb_top.dut.uartA.uart_rx_inst.fifo_inst.wr_en;

    // Side B Internal Connections (uartB use kiya)
    assign spy_rx_data_B  = tb_top.dut.uartB.uart_rx_inst.fifo_inst.data_in;
    assign spy_rx_valid_B = tb_top.dut.uartB.uart_rx_inst.fifo_inst.wr_en;

endinterface