## bme280_diag.xdc — BME280 I2C diagnostic
## Nexys A7-100T

set_property -dict { PACKAGE_PIN E3  IOSTANDARD LVCMOS33 } [get_ports { clk }]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk }]
set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 } [get_ports { resetn }]

## BME280 I2C (JC Pmod)
set_property -dict { PACKAGE_PIN K1  IOSTANDARD LVCMOS33 } [get_ports { bme_sda }]
set_property -dict { PACKAGE_PIN F6  IOSTANDARD LVCMOS33 } [get_ports { bme_scl }]
set_property PULLUP true [get_ports { bme_sda }]
set_property PULLUP true [get_ports { bme_scl }]

## 7-segment anodes
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports { seg_an[0] }]
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS33 } [get_ports { seg_an[1] }]
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports { seg_an[2] }]
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports { seg_an[3] }]
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports { seg_an[4] }]
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 } [get_ports { seg_an[5] }]
set_property -dict { PACKAGE_PIN K2  IOSTANDARD LVCMOS33 } [get_ports { seg_an[6] }]
set_property -dict { PACKAGE_PIN U13 IOSTANDARD LVCMOS33 } [get_ports { seg_an[7] }]

## 7-segment cathodes
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { seg_cat[0] }]
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports { seg_cat[1] }]
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports { seg_cat[2] }]
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [get_ports { seg_cat[3] }]
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports { seg_cat[4] }]
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports { seg_cat[5] }]
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports { seg_cat[6] }]
set_property -dict { PACKAGE_PIN H15 IOSTANDARD LVCMOS33 } [get_ports { seg_dp }]

## LEDs
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports { led[0] }]
set_property -dict { PACKAGE_PIN K15 IOSTANDARD LVCMOS33 } [get_ports { led[1] }]
set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS33 } [get_ports { led[2] }]
set_property -dict { PACKAGE_PIN N14 IOSTANDARD LVCMOS33 } [get_ports { led[3] }]

set_false_path -from [get_ports { resetn   }]
set_false_path -from [get_ports { bme_sda  }]
set_false_path -to   [get_ports { bme_sda  }]
set_false_path -to   [get_ports { bme_scl  }]
set_false_path -to   [get_ports { seg_an[*]}]
set_false_path -to   [get_ports { seg_cat[*]}]
set_false_path -to   [get_ports { seg_dp   }]
set_false_path -to   [get_ports { led[*]   }]
