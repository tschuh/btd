create_clock -period [expr {round(1.0e6 / 240.0) / 1.0e3}] [get_ports clk]
set_property HD.CLK_SRC BUFGCTRL_X0Y0 [get_ports clk]