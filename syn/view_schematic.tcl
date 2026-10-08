# Load and elaborate the RTL in RTL Compiler, then open its GUI schematic view.
if {[info exists env(LIBERTY)]} {
    set liberty $env(LIBERTY)
} else {
    set liberty [file normalize lib/slow.lib]
}
set_attr lib_search_path [file dirname $liberty]
set_attr library [file tail $liberty]

if {[info exists env(NETLIST)] && [file exists $env(NETLIST)]} {
    # Reuse the mapped netlist created by `make build` rather than synthesizing again.
    read_hdl -v2001 $env(NETLIST)
} else {
    set hdl_paths {}
    foreach source $env(RTL_FILES) {
        lappend hdl_paths [file dirname $source]
    }
    set_attr hdl_search_path $hdl_paths
    foreach source $env(RTL_FILES) {
        read_hdl -v2001 $source
    }
    elaborate $env(DESIGN)
    synthesize -to_mapped -effort medium
}
gui_show
