# =====================================================
# Build automático - Display 7 segmentos
# Vivado 2022.2
# =====================================================

set PROJECT_NAME sevenseg_project
set TOP_MODULE   sevenseg_test
set PART         xc7s50csga324-1

# Diretório onde este script está
set SCRIPT_DIR [file dirname [file normalize [info script]]]

# Diretório raiz do projeto (pai de tcl/ e src/)
set ROOT_DIR [file normalize "$SCRIPT_DIR/.."]
set SRC_DIR      $ROOT_DIR/src
set XDC_FILE     $ROOT_DIR/constraints/boolean_board.xdc
set BUILD_DIR    $ROOT_DIR/build

file mkdir $BUILD_DIR
cd $BUILD_DIR

create_project $PROJECT_NAME . -part $PART -force
set_property top $TOP_MODULE [get_filesets sources_1]

add_files [glob $SRC_DIR/*.v]
add_files -fileset constrs_1 $XDC_FILE

update_compile_order -fileset sources_1

puts ">>> Síntese"
launch_runs synth_1 -jobs 4
wait_on_run synth_1

puts ">>> Implementação"
launch_runs impl_1 -jobs 4
wait_on_run impl_1

puts ">>> Gerando bitstream"
open_run impl_1
write_bitstream -force ${PROJECT_NAME}.bit

report_utilization      -file utilization.rpt
report_timing_summary  -file timing.rpt
report_power            -file power.rpt

puts "=== BUILD FINALIZADO ==="
exit
