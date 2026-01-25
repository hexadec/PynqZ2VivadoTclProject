set script_location [file normalize [info script]]
set project_folder [file dirname $script_location]
set project_folder_split [split $project_folder /]
set project_name [lindex $project_folder_split end]
puts "Project folder: ${project_folder}"
puts "Project name: ${project_name}"
open_project ${project_folder}/${project_name}.xpr
set_property top tb_axi4_lite_gpu [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

launch_simulation
