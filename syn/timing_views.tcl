# One slow timing view for the educational GPDK045 implementation flow.
set tech [file join $env(PDK) TECH]
set gpdk [file join $env(PDK) LIBS GPDK045]
create_library_set -name libs_slow -timing [list [file join $gpdk timing slow.lib]]
create_rc_corner -name rc_slow -cap_table [file join $tech capTable] \
    -qx_tech_file [file join $tech qrcTechFile] -T 125
create_delay_corner -name delay_slow -library_set libs_slow -rc_corner rc_slow
create_constraint_mode -name functional -sdc_files [list $env(SDC)]
create_analysis_view -name view_slow -constraint_mode functional \
    -delay_corner delay_slow
set_analysis_view -setup [list view_slow] -hold [list view_slow]
