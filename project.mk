# Project-specific design inputs. Add RTL files to this list as the design grows.
DESIGN := microprocessor
RTL_SOURCES := \
	rtl/bus/address.v \
	rtl/bus/data.v \
	rtl/bus/control.v \
	rtl/memory/rom.v \
	rtl/memory/ram.v \
	rtl/memory/register_file.v \
	rtl/memory/program_counter.v \
	rtl/memory/instruction_register.v \
	rtl/memory/flags.v \
	rtl/memory/output_register.v \
	rtl/execute/alu.v \
	rtl/execute/branch_unit.v \
	rtl/execute/datapath.v \
	rtl/control_unit/instructions/00_nop.v \
	rtl/control_unit/instructions/01_movi.v \
	rtl/control_unit/instructions/02_mov.v \
	rtl/control_unit/instructions/03_add.v \
	rtl/control_unit/instructions/04_sub.v \
	rtl/control_unit/instructions/05_cmp.v \
	rtl/control_unit/instructions/06_load.v \
	rtl/control_unit/instructions/07_store.v \
	rtl/control_unit/instructions/08_jmp.v \
	rtl/control_unit/instructions/09_beq.v \
	rtl/control_unit/instructions/10_bne.v \
	rtl/control_unit/instructions/11_in.v \
	rtl/control_unit/instructions/12_out.v \
	rtl/control_unit/instructions/255_halt.v \
	rtl/control_unit/instruction_decoder.v \
	rtl/control_unit/controller.v \
	rtl/control_unit/control_unit.v \
	rtl/microprocessor.v
TESTBENCH := tb/microprocessor_test.v
SIM_TOP := microprocessor_test

# Timing constraints are design-specific. Review ports and clocks before reuse.
CONSTRAINTS := syn/constraints.sdc
