set_false_path -from [get_pins myReset/nresetLoc_reg/C] -to [get_pins r_reset_n__reg/D]





create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 2 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list openaars_virtual_top/amiga_clk/amiga_clk_i/c0]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {openaars_virtual_top/mycfide/d[0]} {openaars_virtual_top/mycfide/d[1]} {openaars_virtual_top/mycfide/d[2]} {openaars_virtual_top/mycfide/d[3]} {openaars_virtual_top/mycfide/d[4]} {openaars_virtual_top/mycfide/d[5]} {openaars_virtual_top/mycfide/d[6]} {openaars_virtual_top/mycfide/d[7]} {openaars_virtual_top/mycfide/d[8]} {openaars_virtual_top/mycfide/d[9]} {openaars_virtual_top/mycfide/d[10]} {openaars_virtual_top/mycfide/d[11]} {openaars_virtual_top/mycfide/d[12]} {openaars_virtual_top/mycfide/d[13]} {openaars_virtual_top/mycfide/d[14]} {openaars_virtual_top/mycfide/d[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 16 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {openaars_virtual_top/mycfide/I2Cdata[0]} {openaars_virtual_top/mycfide/I2Cdata[1]} {openaars_virtual_top/mycfide/I2Cdata[2]} {openaars_virtual_top/mycfide/I2Cdata[3]} {openaars_virtual_top/mycfide/I2Cdata[4]} {openaars_virtual_top/mycfide/I2Cdata[5]} {openaars_virtual_top/mycfide/I2Cdata[6]} {openaars_virtual_top/mycfide/I2Cdata[7]} {openaars_virtual_top/mycfide/I2Cdata[8]} {openaars_virtual_top/mycfide/I2Cdata[9]} {openaars_virtual_top/mycfide/I2Cdata[10]} {openaars_virtual_top/mycfide/I2Cdata[11]} {openaars_virtual_top/mycfide/I2Cdata[12]} {openaars_virtual_top/mycfide/I2Cdata[13]} {openaars_virtual_top/mycfide/I2Cdata[14]} {openaars_virtual_top/mycfide/I2Cdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 30 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {openaars_virtual_top/mycfide/addr[2]} {openaars_virtual_top/mycfide/addr[3]} {openaars_virtual_top/mycfide/addr[4]} {openaars_virtual_top/mycfide/addr[5]} {openaars_virtual_top/mycfide/addr[6]} {openaars_virtual_top/mycfide/addr[7]} {openaars_virtual_top/mycfide/addr[8]} {openaars_virtual_top/mycfide/addr[9]} {openaars_virtual_top/mycfide/addr[10]} {openaars_virtual_top/mycfide/addr[11]} {openaars_virtual_top/mycfide/addr[12]} {openaars_virtual_top/mycfide/addr[13]} {openaars_virtual_top/mycfide/addr[14]} {openaars_virtual_top/mycfide/addr[15]} {openaars_virtual_top/mycfide/addr[16]} {openaars_virtual_top/mycfide/addr[17]} {openaars_virtual_top/mycfide/addr[18]} {openaars_virtual_top/mycfide/addr[19]} {openaars_virtual_top/mycfide/addr[20]} {openaars_virtual_top/mycfide/addr[21]} {openaars_virtual_top/mycfide/addr[22]} {openaars_virtual_top/mycfide/addr[23]} {openaars_virtual_top/mycfide/addr[24]} {openaars_virtual_top/mycfide/addr[25]} {openaars_virtual_top/mycfide/addr[26]} {openaars_virtual_top/mycfide/addr[27]} {openaars_virtual_top/mycfide/addr[28]} {openaars_virtual_top/mycfide/addr[29]} {openaars_virtual_top/mycfide/addr[30]} {openaars_virtual_top/mycfide/addr[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 1 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list openaars_virtual_top/mycfide/i2c_select]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list openaars_virtual_top/mycfide/scl_i]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list openaars_virtual_top/mycfide/scl_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list openaars_virtual_top/mycfide/scl_t]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list openaars_virtual_top/mycfide/sda_i]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list openaars_virtual_top/mycfide/sda_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list openaars_virtual_top/mycfide/sda_t]]
create_debug_core u_ila_1 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
set_property ALL_PROBE_SAME_MU_CNT 2 [get_debug_cores u_ila_1]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_1]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_1]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_1]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_1]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
set_property port_width 1 [get_debug_ports u_ila_1/clk]
connect_debug_port u_ila_1/clk [get_nets [list openaars_virtual_top/amiga_clk/amiga_clk_i/c1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
set_property port_width 8 [get_debug_ports u_ila_1/probe0]
connect_debug_port u_ila_1/probe0 [get_nets [list {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/data_in[0]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/data_in[1]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/data_in[2]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/data_in[3]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/data_in[4]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/data_in[5]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/data_in[6]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/data_in[7]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe1]
set_property port_width 16 [get_debug_ports u_ila_1/probe1]
connect_debug_port u_ila_1/probe1 [get_nets [list {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/i2c_prescale[0]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/i2c_prescale[1]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/i2c_prescale[2]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/i2c_prescale[3]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/i2c_prescale[4]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/i2c_prescale[5]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/i2c_prescale[6]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/i2c_prescale[7]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/i2c_prescale[8]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/i2c_prescale[9]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/i2c_prescale[10]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/i2c_prescale[11]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/i2c_prescale[12]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/i2c_prescale[13]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/i2c_prescale[14]} {openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/i2c_prescale[15]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe2]
set_property port_width 1 [get_debug_ports u_ila_1/probe2]
connect_debug_port u_ila_1/probe2 [get_nets [list openaars_virtual_top/mycfide/i2c_master.my_i2c_mmio/data_in_valid]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets dv_cecclk_OBUF]
