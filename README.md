Overview
This project implements a hardware accelerator for a specific application, integrated within a standard user project wrapper for use in a system-on-chip (SoC) environment. The accelerator includes various processing elements (PEs), a global buffer, and a ReLU module, controlled by a top-level controller module. The project is designed to be instantiated within a user-defined project wrapper that interfaces with a Wishbone bus, Logic Analyzer, and general-purpose I/O pins.


Directory Structure:  
.  
├── README.md  
├── user_project_wrapper.v  
├── user_proj_accelerator.v  
├── TopLevelKWS.v  
├── Control.v  
├── GlobalBuffer.v  
├── ReLU.v  
├── PE.v  
└── testbench  
    └── accelerator_tb.v  

Files
Top-Level Modules  
user_project_wrapper.v: The top-level module that interfaces with the Wishbone bus, Logic Analyzer, and IOs. It instantiates the user_proj_accelerator module.  
  
user_proj_accelerator.v: This module handles the connections to the Wishbone bus, Logic Analyzer, and IO signals. It instantiates the TopLevelKWS module.  
  
Accelerator Modules  
TopLevelKWS.v: This module integrates the control logic, global buffer, ReLU, and PE modules. It manages the data flow and computation.  
  
Control.v: The control module that manages the state transitions and control signals for the accelerator.  
  
GlobalBuffer.v: A global buffer module acting as a data buffer for the accelerator.  
  
ReLU.v: A ReLU activation function module.  
  
PE.v: Processing element module that handles multiplication and accumulation.  
  
Testbench  
testbench/accelerator_tb.v: A testbench for simulating and verifying the functionality of the hardware accelerator.  

How to Use:  
Simulation  
Setup: Ensure you have a Verilog simulator installed (e.g., ModelSim, VCS).  
Compile: Compile all the Verilog files along with the testbench.  
Run: Execute the simulation.  

Synthesis  
Setup: Ensure you have a synthesis tool installed (e.g., Synopsys Design Compiler, Yosys).  
Synthesize: Run the synthesis tool with the top-level module user_project_wrapper.v.  

Integration  
Wishbone Bus: The accelerator is designed to interface with a Wishbone bus. Ensure the Wishbone signals are correctly connected in the user_project_wrapper module.  
Logic Analyzer: Connect the Logic Analyzer signals as required to monitor internal signals.  
IO Pins: Map the IO signals appropriately for your application.  

Pin Mapping  
Wishbone Interface  
wb_clk_i: Wishbone clock input.  
wb_rst_i: Wishbone reset input.  
wbs_stb_i: Wishbone strobe input.  
wbs_cyc_i: Wishbone cycle input.  
wbs_we_i: Wishbone write enable input.  
wbs_sel_i: Wishbone select input.  
wbs_dat_i: Wishbone data input.  
wbs_adr_i: Wishbone address input.  
wbs_ack_o: Wishbone acknowledge output.  
wbs_dat_o: Wishbone data output.  
Logic Analyzer  
la_data_in: Logic Analyzer data input.  
la_data_out: Logic Analyzer data output.  
la_oenb: Logic Analyzer output enable.  
IOs  
io_in: General-purpose input pins.  
io_out: General-purpose output pins.  
io_oeb: General-purpose output enable.  
Analog IO  
analog_io: Direct connection to GPIO pad.  
Clock  
user_clock2: Independent clock input.  
Interrupts  
user_irq: User maskable interrupt signals.  
License  
This project is licensed under the MIT License.  

Contributing  
Contributions are welcome! Please follow the standard GitHub flow: fork the repository, make your changes, and submit a pull request.  
  
Contact  
For any questions or support, please open an issue on the GitHub repository or contact the project maintainer.  
