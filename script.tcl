set script_location [file normalize [info script]]
set project_folder [file dirname $script_location]
set project_folder_split [split $project_folder /]
set project_name [lindex $project_folder_split end]
puts "Project folder: ${project_folder}"
puts "Project name: ${project_name}"


create_project $project_name $project_folder -part xc7z020clg400-1
set_property board_part tul.com.tw:pynq-z2:part0:1.0 [current_project]
create_fileset -constrset constraints

add_files -fileset constraints "${project_folder}/constraints/constraints.xdc"
set_property constrset constraints [get_runs synth_1]
set_property constrset constraints [get_runs impl_1]


add_files -fileset sources_1 "${project_folder}/sources/block.v"
add_files -fileset sources_1 "${project_folder}/sources/fbuf2rgb.v"
add_files -fileset sources_1 "${project_folder}/sources/framebuffer.v"
add_files -fileset sources_1 "${project_folder}/sources/color_converter.v"
add_files -fileset sources_1 "${project_folder}/sources/test_pattern_generator.v"
update_compile_order -fileset sources_1
file mkdir "${project_folder}/block_design"
create_bd_design -dir "${project_folder}/block_design" design_1
update_compile_order -fileset sources_1

set_property ip_repo_paths "${project_folder}/vivado-library" [current_project]
update_ip_catalog

startgroup

create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config { \
	make_external "FIXED_IO, DDR" \
	apply_board_preset "1" \
	Master "Disable" \
	Slave "Disable" \
} [get_bd_cells processing_system7_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0
create_bd_cell -type ip -vlnv digilentinc.com:ip:rgb2dvi:1.4 rgb2dvi_0
create_bd_cell -type module -reference block block_0
create_bd_cell -type module -reference framebuffer framebuffer_0
create_bd_cell -type module -reference fbuf2rgb fbuf2rgb_0
create_bd_cell -type module -reference color_converter color_converter_0
create_bd_cell -type module -reference test_pattern_generator test_pattern_generat_0

set_property -dict [list \
  CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {100} \
  CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {400} \
  CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
  CONFIG.PCW_USE_M_AXI_GP0 {0} \
  CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {0} \
  CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {0} \
  CONFIG.PCW_SD0_PERIPHERAL_ENABLE {0} \
  CONFIG.PCW_USB0_PERIPHERAL_ENABLE {0} \
] [get_bd_cells processing_system7_0]

set_property -dict [list \
  CONFIG.CLKOUT1_JITTER {217.614} \
  CONFIG.CLKOUT1_PHASE_ERROR {245.344} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {148.5} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {37.125} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {6.250} \
  CONFIG.MMCM_DIVCLK_DIVIDE {4} \
  CONFIG.RESET_PORT {resetn} \
  CONFIG.RESET_TYPE {ACTIVE_LOW} \
] [get_bd_cells clk_wiz_0]

set_property CONFIG.kRstActiveHigh {false} [get_bd_cells rgb2dvi_0]

endgroup

connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins clk_wiz_0/clk_in1]
connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins test_pattern_generat_0/clk]
connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins framebuffer_0/clk_wr]
connect_bd_net [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins clk_wiz_0/resetn]
connect_bd_net [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins fbuf2rgb_0/rst_n]
connect_bd_net [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rgb2dvi_0/aRst_n]
connect_bd_net [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins test_pattern_generat_0/rst_n]
create_bd_port -dir O -from 3 -to 0 led
connect_bd_net [get_bd_ports led] [get_bd_pins block_0/out_led]
create_bd_port -dir I -from 3 -to 0 btn
connect_bd_net [get_bd_ports btn] [get_bd_pins block_0/in_btn]
apply_board_connection -board_interface "hdmi_out" -ip_intf "rgb2dvi_0/TMDS" -diagram "design_1"
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins block_0/clk]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins rgb2dvi_0/PixelClk]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins framebuffer_0/clk_rd]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins fbuf2rgb_0/clk]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins color_converter_0/clk]
connect_bd_net [get_bd_pins test_pattern_generat_0/pixel_fbuf_address] [get_bd_pins framebuffer_0/addr_wr]
connect_bd_net [get_bd_pins test_pattern_generat_0/pixel_fbuf_wr_en] [get_bd_pins framebuffer_0/wrea]
connect_bd_net [get_bd_pins test_pattern_generat_0/pixel_fbuf_wr_en] [get_bd_pins framebuffer_0/en_wr]
connect_bd_net [get_bd_pins test_pattern_generat_0/pixel_fbuf_color] [get_bd_pins framebuffer_0/din]
connect_bd_net [get_bd_pins framebuffer_0/dout] [get_bd_pins color_converter_0/in_color]
connect_bd_net [get_bd_pins color_converter_0/out_color] [get_bd_pins rgb2dvi_0/vid_pData]
connect_bd_net [get_bd_pins fbuf2rgb_0/hsync] [get_bd_pins rgb2dvi_0/vid_pHSync]
connect_bd_net [get_bd_pins fbuf2rgb_0/vsync] [get_bd_pins rgb2dvi_0/vid_pVSync]
connect_bd_net [get_bd_pins fbuf2rgb_0/vde] [get_bd_pins rgb2dvi_0/vid_pVDE]
connect_bd_net [get_bd_pins fbuf2rgb_0/pixel_fbuf_address] [get_bd_pins framebuffer_0/addr_rd]
connect_bd_net [get_bd_pins fbuf2rgb_0/vde] [get_bd_pins framebuffer_0/en_rd]
regenerate_bd_layout
save_bd_design
make_wrapper -files [get_files "${project_folder}/block_design/design_1/design_1.bd"] -top
add_files -norecurse "${project_folder}/block_design/design_1/hdl/design_1_wrapper.v"
set_property top design_1_wrapper [current_fileset]
update_compile_order -fileset sources_1

create_run synthesis1 -flow {Vivado Synthesis 2025}
create_run implementation1 -parent_run synthesis1 -flow {Vivado Implementation 2025}
current_run [get_runs synthesis1]

