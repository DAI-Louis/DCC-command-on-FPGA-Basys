# DCC Command on FPGA (SoC / Microblaze)

## Overview
This repository contains the hardware and software implementation of a Digital Command Control (DCC) station on a Xilinx Artix-7 FPGA. The project utilizes a Hardware/Software Co-design approach to generate precise DCC signals used for controlling model trains (speed, direction, and specific locomotive functions). 

The system relies on a custom hardware IP for strict signal timing generation and a Microblaze softcore processor for frame computation and user interface management.

## Key Features

### Hardware Design (VHDL)
*   **Custom DCC IP:** Development of a dedicated hardware module to generate DCC-compliant bitstreams (100 µs for '0' bits and 58 µs for '1' bits) using Finite State Machines (FSMs) and precise timers.
*   **AXI Integration:** The core logic is encapsulated within an AXI4-Lite wrapper, allowing seamless communication with the processor via the AXI bus.
*   **Shift Registers:** Hardware handling of the DCC frame transmission to ensure uninterrupted signal generation.

### Software Architecture (C / Vitis)
*   **Microblaze Processor:** A softcore processor manages the high-level logic and user interactions.
*   **Frame Computation:** Dynamic construction of the DCC frames based on user inputs (locomotive address, speed steps, functions, and XOR checksum calculation).
*   **GPIO Management:** Real-time polling of the FPGA board's switches and buttons to trigger commands.

## Validation
*   **Simulation & Synthesis:** Behavioral simulation of the VHDL modules (Testbenches) and synthesis via Xilinx Vivado.
*   **Physical Verification:** Signal timing validation using an oscilloscope and successful deployment on a real model railway setup.

## Technologies Used
*   **Hardware Description:** VHDL
*   **Software Development:** C
*   **Tools:** Xilinx Vivado, Vitis, System-on-Chip (SoC) methodology
*   **Protocols/Buses:** DCC Standard, AXI4
