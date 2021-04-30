#!/usr/bin/tclsh

source ./tcl_scripts/setenv.tcl
source ./tcl_scripts/scheduling/alap.tcl
source ./tcl_scripts/scheduling/asap.tcl
source ./tcl_scripts/scheduling/list-lambda.tcl
read_design ./data/DFGs/arf.dot
read_library ./data/RTL_libraries/RTL_lib_1.txt

set lambda_start 8

set last_scheduled [lindex [asap] end]
set last_node_scheduled [lindex $last_scheduled 0]
set last_node_operation [get_attribute $last_node_scheduled operation]
set lambda_asap [expr {[lindex $last_scheduled 1] + [get_attribute [get_lib_fu_from_op $last_node_operation] delay] -1}]

puts "Testing list scheduling under timing constraints: ASAP=$lambda_asap, ALAP=$lambda_start"

set list_sched [list_sched_timing $lambda_start $lambda_asap]
puts "NODE, START-TIME"
foreach item $list_sched {
	puts "[get_attribute [lindex $item 0] label], [lindex $item 1]"
}

print_dfg ./data/out/myExample1.dot
print_scheduled_dfg $list_sched ./data/out/myExample1_list_timing.dot
