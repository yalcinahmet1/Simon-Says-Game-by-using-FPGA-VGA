## Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

## Switches
set_property PACKAGE_PIN U18 [get_ports start]
set_property IOSTANDARD LVCMOS33 [get_ports start]

## Reset button
set_property PACKAGE_PIN V17 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

##Difficulty button
set_property PACKAGE_PIN R2 [get_ports difficulty]
set_property IOSTANDARD LVCMOS33 [get_ports difficulty]

## Buttons
set_property PACKAGE_PIN T18 [get_ports {btn[0]}]
set_property PACKAGE_PIN T17 [get_ports {btn[1]}]
set_property PACKAGE_PIN W19 [get_ports {btn[2]}]
set_property PACKAGE_PIN U17 [get_ports {btn[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[*]}]

## LEDs
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
set_property PACKAGE_PIN E19 [get_ports {led[1]}]
set_property PACKAGE_PIN U19 [get_ports {led[2]}]
set_property PACKAGE_PIN V19 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

## Seven Segment Display
set_property PACKAGE_PIN W7 [get_ports {score[0]}]
set_property PACKAGE_PIN W6 [get_ports {score[1]}]
set_property PACKAGE_PIN U8 [get_ports {score[2]}]
set_property PACKAGE_PIN V8 [get_ports {score[3]}]
set_property PACKAGE_PIN U5 [get_ports {score[4]}]
set_property PACKAGE_PIN V5 [get_ports {score[5]}]
set_property PACKAGE_PIN U7 [get_ports {score[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {score[*]}]

## Digit select (anodes)
set_property PACKAGE_PIN U2 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[*]}]

## VGA Connector
set_property PACKAGE_PIN G19 [get_ports {rgb[0]}]
set_property PACKAGE_PIN H19 [get_ports {rgb[1]}]
set_property PACKAGE_PIN J19 [get_ports {rgb[2]}]
set_property PACKAGE_PIN N19 [get_ports {rgb[3]}]
set_property PACKAGE_PIN N18 [get_ports {rgb[4]}]
set_property PACKAGE_PIN L18 [get_ports {rgb[5]}]
set_property PACKAGE_PIN K18 [get_ports {rgb[6]}]
set_property PACKAGE_PIN J18 [get_ports {rgb[7]}]
set_property PACKAGE_PIN J17 [get_ports {rgb[8]}]
set_property PACKAGE_PIN H17 [get_ports {rgb[9]}]
set_property PACKAGE_PIN G17 [get_ports {rgb[10]}]
set_property PACKAGE_PIN D17 [get_ports {rgb[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[*]}]

set_property PACKAGE_PIN P19 [get_ports hsync]
set_property PACKAGE_PIN R19 [get_ports vsync]
set_property IOSTANDARD LVCMOS33 [get_ports hsync]
set_property IOSTANDARD LVCMOS33 [get_ports vsync]