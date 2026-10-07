# RTL Compiler synthesis; RTL_FILES is a Tcl-list of source paths.
set_attr lib_search_path [file dirname $env(LIBERTY)]
set hdl_paths {}
foreach source $env(RTL_FILES) {
    lappend hdl_paths [file dirname $source]
}
set_attr hdl_search_path $hdl_paths
set_attr library [file tail $env(LIBERTY)]

foreach source $env(RTL_FILES) {
    read_hdl -v2001 $source
}
elaborate $env(DESIGN)
read_sdc $env(SDC)
synthesize -to_mapped -effort medium
report gates -power > [file join $env(OUT) gates.rpt]
report timing > [file join $env(OUT) timing.rpt]
report power > [file join $env(OUT) power.rpt]
write_hdl > [file join $env(OUT) "$env(DESIGN).v"]
exit
