# Project-specific design inputs. Add RTL files to this list as the design grows.
DESIGN := half_adder
RTL_SOURCES := rtl/half_adder.v
TESTBENCH := tb/half_adder_test.v
SIM_TOP := half_adder_test

# Timing constraints are design-specific. Review ports and clocks before reuse.
CONSTRAINTS := syn/constraints.sdc
