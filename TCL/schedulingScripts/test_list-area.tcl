#!/usr/bin/tclsh
source ./tcl_scripts/setenv.tcl
source ./tcl_scripts/scheduling/list-area.tcl
read_design ./data/DFGs/arf.dot
read_library ./data/RTL_libraries/RTL_lib_1.txt

set input_bounds {"MUL 1" "ADD 2" "DIV 1"}
puts "Testing list scheduling area constrained with: $input_bounds"

set list_scheduled [list_sched_area $input_bounds]
puts "NODE, START-TIME"
foreach item $list_scheduled {
	puts "[get_attribute [lindex $item 0] label], [lindex $item 1]"
}

print_dfg ./data/out/myExample1.dot
print_scheduled_dfg $list_scheduled ./data/out/myExample1_list_area.dot

