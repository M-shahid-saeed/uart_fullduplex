# UART Full-Duplex Communication Module

## Overview
This project implements a **UART (Universal Asynchronous Receiver/Transmitter) Full-Duplex** communication system.  
It supports **simultaneous transmission and reception** of serial data using independent TX and RX logic blocks.

The design is suitable for **FPGA / HDL-based systems** and follows standard UART timing and framing conventions.

---

## Features
- Full-duplex UART communication (TX & RX simultaneously)
- Configurable baud rate
- Standard UART frame format  
  - 1 Start bit  
  - 8 Data bits  
  - Optional parity (if enabled)  
  - 1 Stop bit
- Modular and reusable design
- Synthesizable and simulation-friendly

---


---

## How It Works
- **Transmitter (TX)** converts parallel data into serial format based on the configured baud rate.
- **Receiver (RX)** samples incoming serial data, reconstructs the data byte, and validates the frame.
- Both modules operate independently, enabling full-duplex communication.

---

## Parameters
| Parameter | Description |
|---------|------------|
| Clock Frequency | System clock driving UART |
| Baud Rate | Communication speed (e.g., 9600, 115200) |
| Data Bits | 8-bit data frame |
| Stop Bits | 1 stop bit |

---

## Simulation
1. Open the testbench file:
2. 2. Run simulation using your preferred simulator (ModelSim / Vivado / Icarus).
3. Observe TX and RX waveforms to verify full-duplex operation.

---

## Tools & Technologies
- HDL: Verilog / VHDL (as applicable)
- Simulation: ModelSim / Vivado Simulator
- Target: FPGA / Digital Logic Systems

---

## Applications
- FPGA-based serial communication
- Embedded systems
- Debug interfaces
- Microcontroller–FPGA communication

---

## Future Improvements
- Parity bit support
- Configurable data length
- FIFO buffering
- Error detection flags

---

## Author
**Muhammad Shahid Saeed**  
GitHub: https://github.com/M-shahid-saeed

---

## License
This project is open-source and available for educational and research purposes.


