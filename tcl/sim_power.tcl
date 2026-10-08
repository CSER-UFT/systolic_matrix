# ============================================================
# Simulação + Power (VCD)
# Vivado 2022.2
# ============================================================

set PROJECT_NAME sevenseg_project
set TOP_RTL      sevenseg_test

# Diretório onde este script está
set SCRIPT_DIR [file dirname [file normalize [info script]]]

# Diretório raiz do projeto (pai de tcl/ e src/)
set ROOT_DIR [file normalize "$SCRIPT_DIR/.."]
set SRC_DIR      $ROOT_DIR/src
set BUILD_DIR    $ROOT_DIR/build
set VCD_FILE     $ROOT_DIR/sevenseg_activity.vcd

if {[file exists $PROJECT_NAME]} {
    file delete -force $PROJECT_NAME
}
if {[file exists $VCD_FILE]} {
    file delete -force $VCD_FILE
}

create_project $PROJECT_NAME . -part xc7s50csga324-1 -force
set_property target_language Verilog [current_project]

add_files $SRC_DIR/sevenseg_test.v
add_files -fileset sim_1 $SRC_DIR/tb_sevenseg_test.v

set_property top $TOP_RTL [get_filesets sources_1]
set_property top tb_sevenseg_test [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

launch_runs synth_1
wait_on_run synth_1

launch_runs impl_1
wait_on_run impl_1

launch_simulation
catch {close_vcd}

open_vcd $VCD_FILE
log_vcd /tb_sevenseg_test/dut/*
run 6 sec
close_vcd
close_sim

puts ">>> VCD gerado: $VCD_FILE"

open_run impl_1
read_vcd $VCD_FILE
report_power -file $BUILD_DIR/sevenseg_power_report.rpt

puts "=== POWER ANALYSIS FINALIZADA ==="
exit
