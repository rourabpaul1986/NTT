#set_property BITSTREAM.GENERAL.RELOCATED 1 [current_design]
#set_property IOB_AUTO_SPRAY TRUE [current_design]

set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
#create_clock -period 50.000 -name clk -waveform {0.000 25.000} -add
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]