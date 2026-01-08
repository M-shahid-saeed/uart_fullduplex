class coverage_collector;
  
    virtual uart_intf vif; 

    // --- MANUAL TRACKING FLAGS (Report ke liye) ---
    bit hit_A_zero, hit_A_max, hit_A_55, hit_A_AA;
    bit hit_B_zero, hit_B_max;
    int count_B_random_hits = 0;

    // ==========================================================
    // Covergroup: Official Coverage (Tool ke liye)
    // ==========================================================
    covergroup cg_uart @(posedge vif.clk);
        option.per_instance = 1; 
        option.comment = "UART Protocol Coverage";

        // --- SECTION A ---
        cp_data_A: coverpoint vif.data_in_A {
            bins zero       = {8'h00};
            bins max        = {8'hFF};
            bins alt_01     = {8'h55};
            bins alt_10     = {8'hAA};
            bins others     = default; 
        }

        cp_start_A: coverpoint vif.tx_start_A {
            bins rise_edge = (0 => 1);
        }

        // --- SECTION B ---
        cp_data_B: coverpoint vif.data_in_B {
            bins zero       = {8'h00};
            bins max        = {8'hFF};
            bins random[]   = {[1:254]}; 
        }

        cp_start_B: coverpoint vif.tx_start_B {
            bins rise_edge = (0 => 1);
        }
        
        cross_A_data_ctrl: cross cp_data_A, cp_start_A;
    endgroup

    // Constructor
    function new(virtual uart_intf vif);
        this.vif = vif;
        cg_uart = new(); 
    endfunction

    // ==========================================================
    // Manual Tracking Task (Sirf Report Display ke liye)
    // ==========================================================
    task run();
        forever begin
            @(posedge vif.clk);
            
            // Track Side A Data hits
            if(vif.tx_start_A) begin
                if(vif.data_in_A == 8'h00) hit_A_zero = 1;
                if(vif.data_in_A == 8'hFF) hit_A_max  = 1;
                if(vif.data_in_A == 8'h55) hit_A_55   = 1;
                if(vif.data_in_A == 8'hAA) hit_A_AA   = 1;
            end

            // Track Side B Data hits
            if(vif.tx_start_B) begin
                if(vif.data_in_B == 8'h00) hit_B_zero = 1;
                if(vif.data_in_B == 8'hFF) hit_B_max  = 1;
                // Count random range hits
                if(vif.data_in_B > 0 && vif.data_in_B < 255) count_B_random_hits++;
            end
        end
    endtask

    // ==========================================================
    // Function to Print "Dot/Cross" Report
    // ==========================================================
    function void report_detailed_coverage();
        $display("\n");
        $display("==========================================================");
        $display(" DETAILED COVERAGE REPORT (BINS STATUS)                   ");
        $display("==========================================================");
        
        $display(" SECTION A: Data Patterns");
        print_status("Zero (0x00)     ", hit_A_zero);
        print_status("Max  (0xFF)     ", hit_A_max);
        print_status("Alt  (0x55)     ", hit_A_55);
        print_status("Alt  (0xAA)     ", hit_A_AA);

        $display("----------------------------------------------------------");
        
        $display(" SECTION B: Data Patterns");
        print_status("Zero (0x00)     ", hit_B_zero);
        print_status("Max  (0xFF)     ", hit_B_max);
        $display(" [INFO] Random Bins Hit Count: %0d", count_B_random_hits);

        $display("----------------------------------------------------------");
        $display(" OVERALL PERCENTAGE: %0.2f%%", cg_uart.get_inst_coverage());
        $display("==========================================================\n");
    endfunction

    // Helper function for visual printing
    function void print_status(string name, bit status);
        if(status)
            $display("   [  OK  ] %s  (Hit)", name);
        else
            $display("   [ MISS ] %s  (Not Covered)", name);
    endfunction

endclass