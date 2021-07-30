






create_pblock pblock_68k
add_cells_to_pblock [get_pblocks pblock_68k] [get_cells -quiet [list openaars_virtual_top/tg68k]]
resize_pblock [get_pblocks pblock_68k] -add {CLOCKREGION_X1Y2:CLOCKREGION_X1Y2}
create_pblock pblock_hostcpu
add_cells_to_pblock [get_pblocks pblock_hostcpu] [get_cells -quiet [list openaars_virtual_top/hostcpu]]
resize_pblock [get_pblocks pblock_hostcpu] -add {SLICE_X52Y50:SLICE_X89Y70}
resize_pblock [get_pblocks pblock_hostcpu] -add {DSP48_X1Y20:DSP48_X2Y27}
resize_pblock [get_pblocks pblock_hostcpu] -add {RAMB18_X1Y20:RAMB18_X3Y27}
resize_pblock [get_pblocks pblock_hostcpu] -add {RAMB36_X1Y10:RAMB36_X3Y13}
create_pblock pblock_sdram
add_cells_to_pblock [get_pblocks pblock_sdram] [get_cells -quiet [list openaars_virtual_top/sdram]]
resize_pblock [get_pblocks pblock_sdram] -add {SLICE_X52Y71:SLICE_X89Y98}
resize_pblock [get_pblocks pblock_sdram] -add {DSP48_X1Y30:DSP48_X2Y37}
resize_pblock [get_pblocks pblock_sdram] -add {RAMB18_X1Y30:RAMB18_X3Y37}
resize_pblock [get_pblocks pblock_sdram] -add {RAMB36_X1Y15:RAMB36_X3Y18}








set_false_path -from [get_pins myReset/nresetLoc_reg/C] -to [get_pins {r_reset_sync_reg[0]/D}]
