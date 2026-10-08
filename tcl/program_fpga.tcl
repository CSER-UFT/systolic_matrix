# ===================================================== 
# Programação automática da FPGA # Vivado 2022.2 
# ===================================================== 

# Diretório onde este script está 
set SCRIPT_DIR [file dirname [file normalize [info script]]] 

# Diretório raiz do projeto (pai de tcl/ e src/) 
set ROOT_DIR [file normalize "$SCRIPT_DIR/.."] 
set BITSTREAM "$ROOT_DIR/build/sevenseg_project.bit" 

if {![file exists $BITSTREAM]} {
    puts "❌ Bitstream não encontrado:" 
    puts " $BITSTREAM" 
    exit 1 
} 

open_hw 
connect_hw_server 
open_hw_target 

set device [lindex [get_hw_devices] 0] 
current_hw_device $device 

puts ">>> Programando: $BITSTREAM" 
set_property PROGRAM.FILE $BITSTREAM $device 
program_hw_devices $device 
refresh_hw_device $device 

puts "✅ FPGA programada com sucesso" 
exit
