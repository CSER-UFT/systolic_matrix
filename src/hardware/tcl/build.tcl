# Build the systolic array for the Spartan-7 part used by this project.
set PROJECT_NAME systolic_array_project
set TOP_MODULE systolic_array
set PART xc7s50csga324-1

set SCRIPT_DIR [file dirname [file normalize [info script]]]
set HARDWARE_DIR [file normalize "$SCRIPT_DIR/.."]
set RTL_DIR [file join $HARDWARE_DIR rtl]
set CONSTRAINTS_FILE [file join $HARDWARE_DIR constraints systolic_array.xdc]
set BUILD_DIR [file join $HARDWARE_DIR build]
set RTL_FILE [file join $RTL_DIR systolic_array.v]

if {![file exists $RTL_FILE]} {
    error "RTL source not found: $RTL_FILE"
}
if {![file exists $CONSTRAINTS_FILE]} {
    error "Board constraints not found: $CONSTRAINTS_FILE. See src/hardware/constraints/README.md before building a bitstream."
}

file mkdir $BUILD_DIR
create_project $PROJECT_NAME $BUILD_DIR -part $PART -force
set_property target_language Verilog [current_project]
set_property top $TOP_MODULE [get_filesets sources_1]
set_property include_dirs [list $RTL_DIR] [get_filesets sources_1]

# systolic_array.v includes block.v, so add only the top-level source.
add_files -fileset sources_1 $RTL_FILE
add_files -fileset constrs_1 $CONSTRAINTS_FILE
update_compile_order -fileset sources_1

puts ">>> Synthesis"
launch_runs synth_1 -jobs 4
wait_on_run synth_1
if {![string match "*Complete*" [get_property STATUS [get_runs synth_1]]]} {
    error "Synthesis did not complete successfully."
}

puts ">>> Implementation"
launch_runs impl_1 -jobs 4
wait_on_run impl_1
if {![string match "*Complete*" [get_property STATUS [get_runs impl_1]]]} {
    error "Implementation did not complete successfully."
}

puts ">>> Writing implementation reports"
open_run impl_1
report_utilization -file [file join $BUILD_DIR utilization.rpt]
report_timing_summary -file [file join $BUILD_DIR timing.rpt]
report_power -file [file join $BUILD_DIR power.rpt]

puts "=== SYSTOLIC ARRAY ANALYSIS COMPLETE ==="
puts "No bitstream was generated: only clk is physically constrained."
exit
