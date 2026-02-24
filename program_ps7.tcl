set script_location [file normalize [info script]]
set project_folder [file dirname $script_location]
set project_folder_split [split $project_folder /]
set project_name [lindex $project_folder_split end]
puts "Project folder: ${project_folder}"
puts "Project name: ${project_name}"

source "${project_folder}/block_design/design_1/ip/design_1_processing_system7_0_0/ps7_init.tcl"
connect
bpremove -all
targets -set -filter {name =~ "APU*"}
rst -system
after 3000
fpga ${project_folder}/${project_name}.runs/implementation1/design_1_wrapper.bit
targets -set -filter {name =~ "APU*"}
loadhw -hw "${project_folder}/design_1_wrapper.xsa" -mem-ranges [list {0x40000000 0xbfffffff}]
configparams force-mem-access 1
targets -set -filter {name =~ "*A9*#0"}
ps7_init
ps7_post_config
rst -processor
con
configparams force-mem-access 0
