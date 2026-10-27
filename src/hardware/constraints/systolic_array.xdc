###############################################################################
# Constraints for implementation and analysis of systolic_array.
#
# This is an analysis-only XDC. Only the board clock is a physical interface;
# inp_west, inp_north, rst and done have no board-pin assignments yet. Do not
# invent input/output delays for an interface that has not been defined.
#
# F14 and LVCMOS33 are taken from the repository's Boolean Board constraint.
# Confirm them with the board schematic before using another board.
###############################################################################

# 100 MHz oscillator: 10 ns period.
set_property PACKAGE_PIN F14 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -name clk -period 10.000 [get_ports clk]

# No false paths: Vivado must analyse every register-to-register path in the
# 16x16 systolic datapath.
