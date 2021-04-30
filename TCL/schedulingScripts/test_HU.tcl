#!/usr/bin/tclsh

source ./tcl_scripts/setenv.tcl
source ./tcl_scripts/scheduling/HU.tcl
read_design ./data/DFGs/arf.dot
read_library ./data/RTL_libraries/RTL_lib_1.txt
set hw_availability 3


puts "testing HU's with $hw_availability hardware resources constraints"
set hu_scheduled [lsort -index 1 [HUs 3]]
puts "NODE, START-TIME"
foreach item $hu_scheduled {
	puts "[get_attribute [lindex $item 0] label], [lindex $item 1]"
}

print_dfg ./data/out/myExample1.dot
print_scheduled_dfg $hu_scheduled ./data/out/myExample1_HU.dot
