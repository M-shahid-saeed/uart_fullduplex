module shift_register_tx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD_RATE = 19200
)(
    input  logic       clk, rst, fifo_empty,
    input  logic [7:0] dout,
    output logic       read_enable, tx_pin, transmission_complete
);

    localparam integer BAUD_TICK_CNT = CLK_FREQ / BAUD_RATE;
    logic [15:0] baud_cnt;
    logic        baud_tick;
    logic [9:0]  shift_reg;
    logic [3:0]  bit_cnt;
    logic [1:0]  state;

    // States: SKIP hata diya hai
    localparam [1:0] IDLE = 0, LOAD = 1, TRANSMIT = 2;

    assign baud_tick = (baud_cnt == BAUD_TICK_CNT - 1);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            baud_cnt              <= 0;
            shift_reg             <= 10'b1111111111;
            bit_cnt               <= 0;
            tx_pin                <= 1;
            read_enable           <= 0;
            state                 <= IDLE;
            transmission_complete <= 1;
        end 
        else begin
            // Baud Counter Logic
            if (baud_cnt >= BAUD_TICK_CNT - 1)
                baud_cnt <= 0;
            else
                baud_cnt <= baud_cnt + 1;

            case (state)
                IDLE: begin
                    tx_pin                <= 1;
                    read_enable           <= 0;
                    transmission_complete <= 1;
                    
                    if (!fifo_empty)
                        state <= LOAD;
                end

                LOAD: begin
                    // --- FIX: Remove if(dout!=0) check ---
                    // Ab chahe data 0x00 ho ya kuch aur, sab transmit hoga
                    shift_reg   <= {1'b1, dout, 1'b0}; // Stop(1) + Data + Start(0)
                    bit_cnt     <= 0;
                    read_enable <= 1;       // FIFO se data nikalne ke liye pulse
                    transmission_complete <= 0;
                    
                    // --- FIX: Sync Baud Counter ---
                    // Naya packet shuru karte waqt counter reset karna zaroori hai
                    baud_cnt    <= 0;       
                    
                    state       <= TRANSMIT;
                end

                TRANSMIT: begin
                    read_enable <= 0; // Pulse khatam
                    
                    if (baud_tick) begin
                        tx_pin    <= shift_reg[0]; // LSB First (Start bit pehle jayega)
                        shift_reg <= shift_reg >> 1;
                        bit_cnt   <= bit_cnt + 1;
                        
                        // Total 10 bits: 1 Start + 8 Data + 1 Stop
                        if (bit_cnt == 9) begin
                            state                 <= IDLE;
                            tx_pin                <= 1; // Idle line high hoti hai
                            transmission_complete <= 1;
                        end
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule