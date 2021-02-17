## Introduction
This repository contains the work of Christoph Buchner, Simon Michael Laube and Stefan Riesenberger for the exercise `384.178 Lab SoC Design` at the TU Wien ICT.
The topic was "Approximate Computing" where multiple approaches for an approximate square root engine were implemented to process images for a lossy 50% compression of the data.
For the hardware a Nexys 4 DDR Artix-7 FPGA board was used in conjunction with the Vivado IDE from Xilinx.

Additionally to the square root implementations a VHDL based UART implementation for communication between the PC and the FPGA was implemented. The reason for this is the unnecessary overhead of existing IPs offered by the Vivado IDE, which would have bloated the project.

The VHDL files of the implementations can be found in the `vhdl-src` folder. The main file of the project is `env.vhd`, which incorporates the UART and SQRT implementation into one functional block ready for an FPGA. The SQRT engine can be selected by changing the architecture at the component instantiation line. 

### Results
The `results` folder contains the data and images of runs with all avaliable engines on the above mentioned FPGA hardware for your viewing pleasure.

## Simulation and Gate usage
### Simulation
To generate the simulation results of all SQRT engines over the entire number space, you have to simply execute the `generate_data.sh` script. The script will generate a folder structure with a folder for each algorithm containing the simulation results and the used `.vhd` files.

### Generic Synthesis
For the gate wise comparision of the different algorithms a generic synthesis with Yosys in combination with Verific to load the VHDL files were used. Make sure to run the simulation before this step, because the `generate_stats.sh` script isn't generating the needed folder structure.

## Python usbtool
For ease of communication with the FPGA a python tool was created to simplify and partially automate the upload and evaluation of data.
### Dependencies
Make sure to install the following python libraries before using the usbtool.
```
pyserial
numpy
matplotlib
```
### Usage
Execute the python file `usbtool_v2.py` in a terminal and follow the output it prints. The output should be pretty self explanatory.

## Vivado
We had decided to not include the Vivado project folder due to very probable legal issues of distributing the whole Vivado project. Additionally there is the problem of personal data contained inside the project file. This is the reason why only our own VHDL files can be found in this repository.

## License
The license of the whole project can be found in the `LICENSE` file.
