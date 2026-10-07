.DEFAULT_GOAL := build
.PHONY: test build reports view-sim view-schematic view-layout view-reports clean

include project.mk

BUILD := build
SYNTH := $(BUILD)/synthesis
PHYSICAL := $(BUILD)/physical
REPORTS := $(PHYSICAL)/reports

# Override EDI_ROOT when Cadence is installed elsewhere.
EDI_ROOT ?= $(HOME)/cadence/EDI
PDK := $(EDI_ROOT)/share/FoundationFlows/EXAMPLES/EDI/DESIGN/GPDK

RTL_FILES := $(abspath $(RTL_SOURCES))
LIBERTY := $(abspath lib/slow.lib)
SDC := $(abspath $(CONSTRAINTS))
NETLIST := $(abspath $(SYNTH)/$(DESIGN).v)

test:
	@mkdir -p $(BUILD)
	irun -clean -sv -access +rwc -top $(SIM_TOP) -log $(BUILD)/simulation.log \
		-input tb/run.tcl $(RTL_SOURCES) $(TESTBENCH)

build: test
	@mkdir -p $(SYNTH) $(REPORTS)
	cd syn && DESIGN='$(DESIGN)' RTL_FILES='$(RTL_FILES)' LIBERTY='$(LIBERTY)' \
		SDC='$(SDC)' OUT='$(abspath $(SYNTH))' rc -f synthesize.tcl
	cd syn && DESIGN='$(DESIGN)' NETLIST='$(NETLIST)' SDC='$(SDC)' \
		PDK='$(PDK)' OUT='$(abspath $(PHYSICAL))' REPORTS='$(abspath $(REPORTS))' \
		encounter -nowin -init place_route.tcl
	! grep -q '\*\*ERROR' syn/encounter.log
	grep -q 'Total number of DRC violations = 0' syn/encounter.log
	grep -q 'Total number of fails = 0' syn/encounter.log
	grep -E 'Total wire length =|Total number of vias =|Total number of DRC violations =|Total number of fails =|Routing Overflow:|Density for the design' syn/encounter.log > $(REPORTS)/route.rpt
	python tools/vcd_to_svg.py $(BUILD)/microprocessor.vcd $(BUILD)/waveform.svg
	python tools/def_to_svg.py $(PHYSICAL)/$(DESIGN).def \
		$(PDK)/LIBS/GPDK045/gsclib045.lef $(PHYSICAL)/layout.svg
	$(MAKE) reports

reports:
	{ \
		echo '=== Synthesis cells and power ==='; cat $(SYNTH)/gates.rpt; \
		echo '=== Synthesis timing ==='; cat $(SYNTH)/timing.rpt; \
		echo '=== Synthesis power ==='; cat $(SYNTH)/power.rpt; \
		echo '=== Physical design ==='; cat $(REPORTS)/design.rpt; \
		echo '=== Physical area ==='; cat $(REPORTS)/gate_count.rpt; \
		echo '=== Post-route timing ==='; cat $(REPORTS)/$(DESIGN)_postRoute.summary; \
		echo '=== Post-route electrical and routing metrics ==='; \
		cat $(REPORTS)/$(DESIGN)_postRoute.cap $(REPORTS)/$(DESIGN)_postRoute.fanout \
		    $(REPORTS)/$(DESIGN)_postRoute.length $(REPORTS)/$(DESIGN)_postRoute.tran; \
		echo '=== Post-route power ==='; cat $(REPORTS)/power.rpt; \
		echo '=== Routing ==='; cat $(REPORTS)/route.rpt; \
	} > $(BUILD)/reports.txt
	@echo 'Generated reports, waveform, and layout image under $(BUILD)/'

view-sim:
	simvision $(BUILD)/microprocessor.vcd

view-schematic:
	irun -clean -sv -access +rwc -gui -top $(SIM_TOP) $(RTL_SOURCES) $(TESTBENCH)

view-layout:
	cd syn && PNR_DB='$(abspath $(PHYSICAL)/$(DESIGN).enc.dat)' \
		PNR_TOP='$(DESIGN)' encounter -win -init view_layout.tcl

view-reports:
	less $(BUILD)/reports.txt

clean:
	rm -rf $(BUILD) INCA_libs .simvision syn/encounter.log* syn/encounter.cmd* \
		syn/.tdrlog syn/timingReports syn/fv
