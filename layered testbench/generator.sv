`include "transaction.sv"

class generator;
  
  transaction tr;
  mailbox gen2driv;
  event done;
  
  // Constructor
  function new(mailbox gen2driv, event done);
    this.gen2driv = gen2driv;
    this.done     = done; 
  endfunction
  
  // Main Task
  task run();
    // Hum 20 packets bhej rahe hain
    for(int i = 0; i < 255; i++) begin
      tr = new();
      
      // --- NEW: Object Randomization ---
      // Ye transaction class ke "constraints" ko use karega.
      if( !tr.randomize() ) begin
        $fatal("[GEN] Randomization Failed! Check constraints.");
      end
      
      // Agar aapko Coverage ke liye 'corner cases' (00, FF, 55) chahiye,
      // toh aap inline constraints bhi use kar sakte hain, jaise:
       else if (i == 0) tr.randomize() with { data_in_A == 8'h00; };
       else if (i == 1) tr.randomize() with { data_in_A == 8'hFF; };
      
      gen2driv.put(tr);
      
      $display("[GENERATOR] Packet %0d sent: A=%h, B=%h", 
               i+1, tr.data_in_A, tr.data_in_B);
    end
    
    // Trigger Event
    -> done;
    $display("[GENERATOR] Generation Complete. Total 20 packets sent.");
  endtask
  
endclass