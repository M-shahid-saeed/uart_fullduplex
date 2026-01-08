// Interface aur Env include karein (Ensure path sahi ho)
`include "uart_intf.sv" // TCL se compile ho raha hai to include hata den
`include "environment.sv"

module tb_top;
    
    // 1. Clock and Reset Declaration
    bit clk;
    bit rst;

    // 2. Clock Generation (10ns Period -> 100MHz)
    always #5 clk = ~clk;

    // 3. Reset Logic
    initial begin
        rst = 1;
        #20 rst = 0;
    end

    // 4. Interface Instantiation
    // ERROR FIX: Interface definition check karein. Usually ye sirf 'clk' leta hai.
    // Reset hum direct assign kar denge.
    uart_intf vif(clk); 
    
    // Reset ko interface ke internal signal se connect karein
    assign vif.rst = rst;

    // 5. DUT Instantiation (CRITICAL FIX)
    // Hum 'uart_top' nahi, balki 'uart_full_duplex_top' use karenge
    uart_full_duplex_top #(
        .CLK_FREQ(100_000_000),
        .BAUD_RATE(19200)
    ) dut (
        .clk(vif.clk),
        .rst(vif.rst),
        
        // --- A Side ---
        .tx_start_A(vif.tx_start_A),
        .data_in_A(vif.data_in_A),
        .tx_A(vif.tx_A),
        .rx_done_A(vif.rx_done_A),
        .fifo_data_A(vif.fifo_data_A),
        .tx_done_A(vif.tx_done_A), // Ye naya signal add kiya tha humne

        // --- B Side ---
        .tx_start_B(vif.tx_start_B),
        .data_in_B(vif.data_in_B),
        .tx_B(vif.tx_B),
        .rx_done_B(vif.rx_done_B),
        .fifo_data_B(vif.fifo_data_B),
        .tx_done_B(vif.tx_done_B) // Ye naya signal add kiya tha humne
    );

    // 6. Environment Declaration
    environment env; 

    // 7. Test Start Block
    initial begin
        env = new(vif);
        env.run();
    end

    // 8. Waveform Dump
    initial begin
        $dumpfile("uart_dump.vcd");
        $dumpvars(0, tb_top);
    end

endmodule