# -------------------------------------
# 1. Cleanup (Purani library delete karo)
# -------------------------------------
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

# -------------------------------------
# 2. Compile RTL Files (Design)
# Note: Make sure file names match module names
# -------------------------------------
puts "--- Compiling Design Files ---"

# Low level modules first
vlog -sv fifo.sv
vlog -sv fifo_8x16.sv
vlog -sv shift_register_tx.sv
vlog -sv uart_rx.sv

# Mid level wrappers
vlog -sv uart_tx_top.sv
vlog -sv uart_rx_top.sv
vlog -sv uart_top.sv  

# Top Level RTL
vlog -sv uart_full_duplex_top.sv

# -------------------------------------
# 3. Compile Verification Environment
# -------------------------------------
puts "--- Compiling Testbench Files ---"

# Interface pehle compile hona zaroori hai
vlog -sv uart_intf.sv

# 'tb_top.sv' ke andar `include` laga hua hai, 
# isliye baaki files (env, driver, etc.) automatic compile ho jayengi.
# Alag se compile karne ki zaroorat nahi hai agar `include` sahi hai.
vlog -sv tb_top.sv

# -------------------------------------
# 4. Simulation Setup
# -------------------------------------
puts "--- Starting Simulation ---"

# Optimize and Load Simulation (tb_top module load karein)
# -voptargs=+acc Waveform signals dekhne ke liye zaroori hai
vsim -voptargs=+acc work.tb_top

# -------------------------------------
# 5. Add Waves (Optional)
# -------------------------------------
# Interface ke signals add karein
add wave -group "Interface" -radix hexadecimal sim:/tb_top/vif/*

# DUT ke internal signals add karein (Debugging ke liye)
add wave -group "DUT Internal" -radix hexadecimal sim:/tb_top/dut/*

# -------------------------------------
# 6. Run Simulation
# -------------------------------------
# Screen fit karo
view wave
wave zoom full

# Simulation run karo
run -all