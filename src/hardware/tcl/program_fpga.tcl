# Program the FPGA with the bitstream produced by build.tcl.
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set HARDWARE_DIR [file normalize "$SCRIPT_DIR/.."]
set BITSTREAM [file join $HARDWARE_DIR build systolic_array.bit]

if {![file exists $BITSTREAM]} {
    error "Bitstream not found: $BITSTREAM. Run the hardware build first."
}

open_hw
connect_hw_server
open_hw_target

set devices [get_hw_devices]
if {[llength $devices] == 0} {
    error "No FPGA device found. Check the board connection and hardware target."
}

set device [lindex $devices 0]
current_hw_device $device
set_property PROGRAM.FILE $BITSTREAM $device
program_hw_devices $device
refresh_hw_device $device

puts "=== FPGA PROGRAMMED: $BITSTREAM ==="
puts "✅ FPGA programada com sucesso" 
exit
