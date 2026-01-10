set script_location [file normalize [info script]]
set project_folder [file dirname $script_location]
set project_folder_split [split $project_folder /]
set project_name [lindex $project_folder_split end]
puts "Project folder: ${project_folder}"
puts "Project name: ${project_name}"
open_project ${project_folder}/${project_name}.xpr
update_compile_order -fileset sources_1
set props [list_property [get_runs implementation1]]
foreach prop $props {
    set value [get_property $prop [get_runs implementation1]]
    puts "$prop: $value"
}
reset_run implementation1
launch_runs implementation1 -to_step write_bitstream -jobs 4
wait_on_runs implementation1
set run_progress [get_property PROGRESS [get_runs implementation1]]
puts "Run progress: ${run_progress}"
if {${run_progress} != "100%"} {
   error "ERROR: implementation1 failed"
}
open_run implementation1
report_utilization -hierarchical_min_primitive_count 50 -name utilization_1
