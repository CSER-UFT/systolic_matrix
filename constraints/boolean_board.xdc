############################################################
# Clock – 100 MHz (Boolean Board)
############################################################
set_property PACKAGE_PIN F14 [get_ports mclk]
set_property IOSTANDARD LVCMOS33 [get_ports mclk]
create_clock -name mclk -period 10.000 [get_ports mclk]

############################################################
# 7-Segment Display D0 – Anodos (ativos em nível baixo)
############################################################
set_property PACKAGE_PIN A8 [get_ports {D0_a[0]}]
set_property PACKAGE_PIN C7 [get_ports {D0_a[1]}]
set_property PACKAGE_PIN C4 [get_ports {D0_a[2]}]
set_property PACKAGE_PIN D5 [get_ports {D0_a[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {D0_a[*]}]

############################################################
# 7-Segment Display D0 – Segmentos
# Ordem: {dp,g,f,e,d,c,b,a}
############################################################
set_property PACKAGE_PIN D7 [get_ports {D0_seg[0]}] ;# a
set_property PACKAGE_PIN C5 [get_ports {D0_seg[1]}] ;# b
set_property PACKAGE_PIN A5 [get_ports {D0_seg[2]}] ;# c
set_property PACKAGE_PIN B7 [get_ports {D0_seg[3]}] ;# d
set_property PACKAGE_PIN A7 [get_ports {D0_seg[4]}] ;# e
set_property PACKAGE_PIN D6 [get_ports {D0_seg[5]}] ;# f
set_property PACKAGE_PIN B5 [get_ports {D0_seg[6]}] ;# g
set_property PACKAGE_PIN A6 [get_ports {D0_seg[7]}] ;# dp

set_property IOSTANDARD LVCMOS33 [get_ports {D0_seg[*]}]

############################################################
# Segurança elétrica (opcional, mas recomendado)
############################################################
set_property DRIVE 8 [get_ports {D0_a[*] D0_seg[*]}]
set_property SLEW SLOW [get_ports {D0_a[*] D0_seg[*]}]
