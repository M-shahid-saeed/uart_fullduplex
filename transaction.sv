`ifndef TRANSACTION_SV
`define TRANSACTION_SV

class transaction;
  // --- STIMULUS (Randomized Inputs) ---
  
  // 'randc' ensure karega ke jab tak 0 se 255 tak saari values 
  // ek baar na aa jayein, koi value repeat nahi hogi.
  randc bit [7:0] data_in_A;
  randc bit [7:0] data_in_B;
  
  // Control signals ko simple 'rand' rakhein, lekin constraint lagayenge
  rand bit tx_start_A;
  rand bit tx_start_B;

  // --- CONSTRAINTS ---
  constraint valid_packet {
      // Hum chahte hain ke Generator hamesha valid packet banaye.
      // Agar ye 0 ho gaya, to Driver kuch nahi bhejega.
      tx_start_A == 1;
      tx_start_B == 1;
  }

  // Aap chaho to data par bhi limit laga sakte ho (Optional)
  // constraint limit_data {
  //    data_in_A inside {[10:200]}; 
  // }

  // --- ANALYSIS (Output Results) ---
  bit [7:0] actual_rx_data_A; 
  bit [7:0] actual_rx_data_B;
  
  bit rcvd_on_A; // Flag: Kya A ne kuch receive kiya?
  bit rcvd_on_B; // Flag: Kya B ne kuch receive kiya?

  // --- DISPLAY FUNCTION ---
  function void display(string tag="TRANS");
    $display("[%s] DA:%h DB:%h | RxA:%h RxB:%h", 
             tag, data_in_A, data_in_B, actual_rx_data_A, actual_rx_data_B);
  endfunction
  
endclass
`endif