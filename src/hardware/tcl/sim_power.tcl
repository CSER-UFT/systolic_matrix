# Simulate the systolic array, capture switching activity, then report power.
set PROJECT_NAME systolic_power_project
set TOP_MODULE systolic_array
set TESTBENCH sys_array_tb
set PART xc7s50csga324-1

set SCRIPT_DIR [file dirname [file normalize [info script]]]
set HARDWARE_DIR [file normalize "$SCRIPT_DIR/.."]
set RTL_DIR [file join $HARDWARE_DIR rtl]
set CONSTRAINTS_FILE [file join $HARDWARE_DIR constraints systolic_array.xdc]
set BUILD_DIR [file join $HARDWARE_DIR build]
set RTL_FILE [file join $RTL_DIR systolic_array.v]
set TB_FILE [file join $RTL_DIR sys_array_tb.v]
set VCD_FILE [file join $BUILD_DIR systolic_array_activity.vcd]

if {![file exists $RTL_FILE]} {
    error "RTL source not found: $RTL_FILE"
}
if {![file exists $TB_FILE]} {
    error "Testbench not found: $TB_FILE"
}
file mkdir $BUILD_DIR
create_project $PROJECT_NAME [file join $BUILD_DIR $PROJECT_NAME] -part $PART -force
set_property target_language Verilog [current_project]
set_property top $TOP_MODULE [get_filesets sources_1]
set_property include_dirs [list $RTL_DIR] [get_filesets sources_1]
set_property include_dirs [list $RTL_DIR] [get_filesets sim_1]
add_files -fileset sources_1 $RTL_FILE
if {[file exists $CONSTRAINTS_FILE]} {
    add_files -fileset constrs_1 $CONSTRAINTS_FILE
}
add_files -fileset sim_1 $TB_FILE
set_property top $TESTBENCH [get_filesets sim_1]
set_property xsim.simulate.runtime 600ns [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts ">>> Behavioral simulation and VCD capture"
launch_simulation -simset sim_1 -mode behavioral
open_vcd $VCD_FILE
log_vcd /sys_array_tb/uut/*
run 600 ns
close_vcd
close_sim

if {![file exists $CONSTRAINTS_FILE]} {
    error "Simulation and VCD capture completed, but board constraints are missing: $CONSTRAINTS_FILE. See src/hardware/constraints/README.md to enable power analysis."
}

puts ">>> Synthesis and implementation for power estimation"
launch_runs synth_1 -jobs 4
wait_on_run synth_1
if {![string match "*Complete*" [get_property STATUS [get_runs synth_1]]]} {
    error "Synthesis did not complete successfully."
}
launch_runs impl_1 -jobs 4
wait_on_run impl_1
if {![string match "*Complete*" [get_property STATUS [get_runs impl_1]]]} {
    error "Implementation did not complete successfully."
}

open_run impl_1
read_vcd -file $VCD_FILE -strip_path "$TESTBENCH/uut"
report_power -file [file join $BUILD_DIR systolic_array_power_report.rpt]

puts "=== SIMULATION AND POWER ANALYSIS COMPLETE ==="
puts "VCD: $VCD_FILE"

exit
