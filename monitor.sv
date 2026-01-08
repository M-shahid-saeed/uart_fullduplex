`include "transaction.sv"
class monitor;
    virtual uart_intf vif;
    mailbox mon2scb;

    function new(virtual uart_intf vif, mailbox mon2scb);
        this.vif = vif;
        this.mon2scb = mon2scb;
    endfunction

    task run();
        forever begin
            @(posedge vif.clk);

            // --- FILTER: IGNORE INITIAL GLITCHES ---
            // Agar simulation time 600,000ns se kam hai, toh hum maante hain
            // ke UART frame abhi complete nahi hua hoga. Jo bhi abhi aa raha hai
            // wo garbage/reset value hai.
            if ($time < 600000) begin
               continue; 
            end

            // --- CHECK SIDE A RECEIVER ---
            if (vif.spy_rx_valid_A == 1) begin
                transaction tr = new();
                tr.rcvd_on_A = 1;
                tr.actual_rx_data_A = vif.spy_rx_data_A; 
                
                $display("[MON] Side A Received Internally: %h at time %0t", tr.actual_rx_data_A, $time);
                mon2scb.put(tr);
            end

            // --- CHECK SIDE B RECEIVER ---
            if (vif.spy_rx_valid_B == 1) begin
                transaction tr = new();
                tr.rcvd_on_B = 1;
                tr.actual_rx_data_B = vif.spy_rx_data_B;
                
                $display("[MON] Side B Received Internally: %h at time %0t", tr.actual_rx_data_B, $time);
                mon2scb.put(tr);
            end
        end
    endtask
endclass