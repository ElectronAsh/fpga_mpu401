create_clock -name CLOCK_24_0 -period 41.666 [get_ports CLOCK_24[0]]
create_clock -name CLOCK_24_1 -period 41.666 [get_ports CLOCK_24[1]]
create_clock -name CLOCK_27_0 -period 37.037 [get_ports CLOCK_27[0]]
create_clock -name CLOCK_27_1 -period 37.037 [get_ports CLOCK_27[1]]
create_clock -name CLOCK_50 -period 20.000 [get_ports CLOCK_50]

set_input_delay -max -clock SYS_CLK -1.5 [get_ports SRAM_DQ*]
set_input_delay -min -clock SYS_CLK -1.5 [get_ports SRAM_DQ*]

set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_CE_N
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_LB_N
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_OE_N
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_UB_N
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_WE_N
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_ADDR[0]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_ADDR[1]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_ADDR[2]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_ADDR[3]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_ADDR[4]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_ADDR[5]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_ADDR[6]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_ADDR[7]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_ADDR[8]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_ADDR[9]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_ADDR[10]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_ADDR[11]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_ADDR[12]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_ADDR[13]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_ADDR[14]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_ADDR[15]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_ADDR[16]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_ADDR[17]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_DQ[0]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_DQ[1]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_DQ[2]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_DQ[3]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_DQ[4]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_DQ[5]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_DQ[6]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_DQ[7]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_DQ[8]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_DQ[9]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_DQ[10]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_DQ[11]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_DQ[12]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_DQ[13]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_DQ[14]
set_instance_assignment -name CYCLONEII_TERMINATION "SERIES 25 OHMS" -to SRAM_DQ[15]



create_clock -name SYS_CLK -period 20.000 [get_ports SYS_CLK]


create_clock -name sdr_clk -period 10.000 [get_ports DRAM_CLK]
create_generated_clock -name sdr_clk -source [get_ports {DRAM_CLK}]

set_input_delay -max -clock sdr_clk 6.4 [get_ports DRAM_DQ*]
set_input_delay -min -clock sdr_clk 2.7 [get_ports DRAM_DQ*]


#set_multicycle_path -from [get_clocks {sdr_clk}] -to [get_clocks {amiga_clk|amiga_pll|amiga_pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -setup -end 2

set_output_delay -max -clock sdr_clk 1.452  [get_ports DRAM_DQ*]
set_output_delay -min -clock sdr_clk -0.857 [get_ports DRAM_DQ*]

set_output_delay -max -clock sdr_clk 1.531 [get_ports DRAM_ADDR*]
set_output_delay -min -clock sdr_clk -0.805 [get_ports DRAM_ADDR*]
set_output_delay -max -clock sdr_clk 1.533  [get_ports DRAM_*DQM]
set_output_delay -min -clock sdr_clk -0.805 [get_ports DRAM_*DQM]
set_output_delay -max -clock sdr_clk 1.510  [get_ports DRAM_BA_*]
set_output_delay -min -clock sdr_clk -0.800 [get_ports DRAM_BA_*]
set_output_delay -max -clock sdr_clk 1.520  [get_ports DRAM_RAS_N]
set_output_delay -min -clock sdr_clk -0.780 [get_ports DRAM_RAS_N]
set_output_delay -max -clock sdr_clk 1.5000  [get_ports DRAM_CAS_N]
set_output_delay -min -clock sdr_clk -0.800 [get_ports DRAM_CAS_N]
set_output_delay -max -clock sdr_clk 1.545 [get_ports DRAM_WE_N]
set_output_delay -min -clock sdr_clk -0.755 [get_ports DRAM_WE_N]
set_output_delay -max -clock sdr_clk 1.496  [get_ports DRAM_CKE]
set_output_delay -min -clock sdr_clk -0.804 [get_ports DRAM_CKE]
set_output_delay -max -clock sdr_clk 1.508  [get_ports DRAM_CS_N]
set_output_delay -min -clock sdr_clk -0.792 [get_ports DRAM_CS_N]



#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************

