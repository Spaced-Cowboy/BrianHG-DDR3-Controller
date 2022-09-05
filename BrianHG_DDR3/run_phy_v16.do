vlog -sv -work work {altera_gpio_lite.sv}
vlog -sv -work work {BrianHG_DDR3_GEN_tCK.sv}
vlog -sv -work work {BrianHG_DDR3_PLL.sv}
vlog -sv -work work {BrianHG_DDR3_FIFOs.sv}
vlog -sv -work work {BrianHG_DDR3_CMD_SEQUENCER_v16.sv}
vlog -sv -work work {BrianHG_DDR3_IO_PORT_ALTERA.sv}
vlog -sv -work work {BrianHG_DDR3_PHY_SEQ_v16.sv}
vlog -sv -work work {BrianHG_DDR3_PHY_SEQ_v16_tb.sv}

vlog -work work {Gowin/prim_sim.v}
vlog -sv -work work {Gowin/gowin_ddr_clocking.sv}
vlog -sv -work work {Gowin/ddr3_io_port_gowin.sv}


restart -force
run -all

wave cursor active
wave refresh
wave zoom range 1390ns 1420ns
view signals


