set script_location [file normalize [info script]]
set project_folder [file dirname $script_location]
set project_folder_split [split $project_folder /]
set project_name [lindex $project_folder_split end]
puts "Project folder: ${project_folder}"
puts "Project name: ${project_name}"
open_project ${project_folder}/${project_name}.xpr

open_run implementation1
open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target

current_hw_device [get_hw_devices xc7z020_0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7z020_0] 0]
set_property PROBES.FILE {} [get_hw_devices xc7z020_0]
set_property FULL_PROBES.FILE {} [get_hw_devices xc7z020_0]
set_property PROGRAM.FILE ${project_folder}/${project_name}.runs/implementation1/design_1_wrapper.bit [get_hw_devices xc7z020_0]
program_hw_devices [get_hw_devices xc7z020_0]
