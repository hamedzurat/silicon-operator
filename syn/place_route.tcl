# Minimal educational place-and-route flow. Not a signoff flow.
setMultiCpuUsage -localCpu $env(CORES)
set init_verilog $env(NETLIST)
set init_top_cell $env(DESIGN)
set init_lef_file [list [file join $env(PDK) LIBS GPDK045 gsclib045.lef]]
set init_mmmc_file [file join [pwd] timing_views.tcl]
set init_pwr_net VDD
set init_gnd_net VSS

init_design

file mkdir $env(OUT)
file mkdir $env(REPORTS)

# Small educational core; this flow omits clock-tree synthesis.
floorPlan -site CoreSite -r 1.0 0.70 10 10 10 10
globalNetConnect VDD -type pgpin -pin VDD -inst * -override
globalNetConnect VSS -type pgpin -pin VSS -inst * -override
placeDesign
optDesign -preCTS
routeDesign
# Use base timing analysis; SI-aware optimization requires OCV setup and corners.
setDelayCalMode -engine aae -SIAware false
optDesign -postRoute

timeDesign -postRoute -outDir $env(REPORTS)
report_power -outfile [file join $env(REPORTS) power.rpt]
report_design > [file join $env(REPORTS) design.rpt]
reportGateCount -stdCellOnly -outfile [file join $env(REPORTS) gate_count.rpt]

saveDesign [file join $env(OUT) "$env(DESIGN).enc"]
defOut -routing [file join $env(OUT) "$env(DESIGN).def"]

exit
