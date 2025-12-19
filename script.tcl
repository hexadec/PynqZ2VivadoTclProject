set script_location [file normalize [info script]]
set project_folder [file dirname $script_location]
set project_folder_split [split $project_folder /]
set project_name [lindex $project_folder_split end]
puts "Project folder: ${project_folder}"
puts "Project name: ${project_name}"


create_project $project_name $project_folder -part xc7z020clg400-1
set_property board_part tul.com.tw:pynq-z2:part0:1.0 [current_project]
create_fileset -constrset constraints
create_fileset -blockset sources

add_files -fileset constraints "${project_folder}/constraints/constraints.xdc"
set_property constrset constraints [get_runs synth_1]
set_property constrset constraints [get_runs impl_1]


add_files -fileset sources "${project_folder}/sources/block.v"
update_compile_order -fileset sources
file mkdir "${project_folder}/block_design"
create_bd_design -dir "${project_folder}/block_design" design_1
update_compile_order -fileset sources

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
create_bd_cell -type module -reference block block_0

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
  CONFIG.CLKOUT1_JITTER {143.858} \
  CONFIG.CLKOUT1_PHASE_ERROR {157.402} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {150} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {19.875} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {6.625} \
  CONFIG.MMCM_DIVCLK_DIVIDE {2} \
  CONFIG.RESET_PORT {resetn} \
  CONFIG.RESET_TYPE {ACTIVE_LOW} \
] [get_bd_cells clk_wiz_0]

endgroup

connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins clk_wiz_0/clk_in1]
connect_bd_net [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins clk_wiz_0/resetn]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins block_0/clk]
create_bd_port -dir O -from 3 -to 0 led
connect_bd_net [get_bd_ports led] [get_bd_pins block_0/out_led]
create_bd_port -dir I -from 3 -to 0 btn
connect_bd_net [get_bd_ports btn] [get_bd_pins block_0/in_btn]
regenerate_bd_layout
save_bd_design
make_wrapper -files [get_files "${project_folder}/block_design/design_1/design_1.bd"] -top
add_files -norecurse "${project_folder}/block_design/design_1/hdl/design_1_wrapper.v"

create_run synthesis1 -flow {Vivado Synthesis 2025}
create_run implementation1 -parent_run synthesis1 -flow {Vivado Implementation 2025}
delete_run sources_synth_1
current_run [get_runs synthesis1]

