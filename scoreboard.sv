`include "transaction.sv"

class scoreboard;
    mailbox mon2scb;
    transaction tr;
    
    // Queues
    bit [7:0] queue_A_tx[$]; 
    bit [7:0] queue_B_tx[$]; 
    
    // --- STATISTICS COUNTERS ---
    int packets_sent_A = 0;
    int packets_sent_B = 0;
    int packets_rcvd_A = 0; // B -> A
    int packets_rcvd_B = 0; // A -> B
    int total_errors   = 0;
    int total_pass     = 0;

    virtual uart_intf vif;

    function new(mailbox mon2scb, virtual uart_intf vif);
        this.mon2scb = mon2scb;
        this.vif = vif;
    endfunction

    task run();
        fork
            // --- THREAD 1: Track A Transmit ---
            forever begin
                @(posedge vif.clk);
                if(vif.tx_start_A) begin
                   queue_A_tx.push_back(vif.data_in_A);
                   packets_sent_A++; // Count badhaya
                   while(vif.tx_start_A) @(posedge vif.clk); 
                end
            end

            // --- THREAD 2: Track B Transmit ---
            forever begin
                @(posedge vif.clk);
                if(vif.tx_start_B) begin
                   queue_B_tx.push_back(vif.data_in_B);
                   packets_sent_B++; // Count badhaya
                   while(vif.tx_start_B) @(posedge vif.clk);
                end
            end

            // --- THREAD 3: Checker ---
            forever begin
                mon2scb.get(tr);
                
                // Safety Filter (Garbage Ignore)
                if ($time < 600000) continue;

                // --- CHECK A -> B ---
                if(tr.rcvd_on_B) begin
                    packets_rcvd_B++;
                    if(queue_A_tx.size() == 0) begin
                        $error("[SCB] FAIL: Queue A Empty!");
                        total_errors++;
                    end else begin
                        bit [7:0] expected = queue_A_tx.pop_front();
                        if(expected == tr.actual_rx_data_B) begin
                            $display("[SCB] PASS (A->B): %h == %h", expected, tr.actual_rx_data_B);
                            total_pass++;
                        end else begin
                            $error("[SCB] FAIL (A->B): Sent %h != Recv %h", expected, tr.actual_rx_data_B);
                            total_errors++;
                        end
                    end
                end

                // --- CHECK B -> A ---
                if(tr.rcvd_on_A) begin
                    packets_rcvd_A++;
                    if(queue_B_tx.size() == 0) begin
                        $error("[SCB] FAIL: Queue B Empty!");
                        total_errors++;
                    end else begin
                        bit [7:0] expected = queue_B_tx.pop_front();
                        if(expected == tr.actual_rx_data_A) begin
                            $display("[SCB] PASS (B->A): %h == %h", expected, tr.actual_rx_data_A);
                            total_pass++;
                        end else begin
                            $error("[SCB] FAIL (B->A): Sent %h != Recv %h", expected, tr.actual_rx_data_A);
                            total_errors++;
                        end
                    end
                end
            end
        join
    endtask

    // --- NEW FUNCTION: FINAL REPORT ---
    function void report_final_stats();
        $display("\n");
        $display("==========================================================");
        $display("               UART VERIFICATION SCORE CARD               ");
        $display("==========================================================");
        $display(" STATUS          : %s", (total_errors == 0) ? "TEST PASSED" : "TEST FAILED");
        $display("----------------------------------------------------------");
        $display(" Packets Sent (A): %0d", packets_sent_A);
        $display(" Packets Sent (B): %0d", packets_sent_B);
        $display("----------------------------------------------------------");
        $display(" Received on A   : %0d", packets_rcvd_A);
        $display(" Received on B   : %0d", packets_rcvd_B);
        $display("----------------------------------------------------------");
        $display(" SUCCESSFUL CHECKS: %0d", total_pass);
        $display(" FAILED CHECKS    : %0d", total_errors);
        $display("==========================================================\n");
    endfunction

endclass