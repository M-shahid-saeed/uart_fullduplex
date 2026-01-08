`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "coverage_collector.sv" 

class environment;
    generator           gen;
    driver              driv;
    monitor             mon;
    scoreboard          scb;
    coverage_collector  cov; 

    mailbox gen2driv; 
    mailbox mon2scb;  
    event gen_done;   
    virtual uart_intf vif; 

    function new(virtual uart_intf vif);
        this.vif = vif;
        gen2driv = new();
        mon2scb  = new();
        
        gen  = new(gen2driv, gen_done);
        driv = new(gen2driv, vif); 
        mon  = new(vif, mon2scb);
        scb  = new(mon2scb , vif);
        cov  = new(vif); 
    endfunction

    task run();
        $display("[ENV] Simulation Started at %0t", $time);
        
        fork
            gen.run();  
            driv.run(); 
            mon.run();  
            scb.run();  
            cov.run();  // NEW: Manual tracking chalana zaroori hai
        join_any

        // Wait for Generator
        wait(gen_done.triggered); 
        $display("[ENV] Generator Finished. Extending simulation time...");

        // Extend Time
        if ($time < 10441625) begin
            #(10441625 - $time); 
        end
        #1000; 

        // --- PRINT REPORTS ---
        scb.report_final_stats();     // Scoreboard Stats
        cov.report_detailed_coverage(); // NEW: Dot/Cross Report

        $finish; 
    endtask

endclass