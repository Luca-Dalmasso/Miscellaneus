#!/usr/bin/tclsh
source ./tcl_scripts/setenv.tcl
source ./tcl_scripts/scheduling/asap.tcl
read_design ./data/DFGs/arf.dot
read_library ./data/RTL_libraries/RTL_lib_1.txt

set asap_scheduled [asap]
puts "NODE, START-TIME"
foreach item $asap_scheduled {
	puts "[get_attribute [lindex $item 0] label], [lindex $item 1]"
}

print_dfg ./data/out/myExample1.dot
print_scheduled_dfg $asap_scheduled ./data/out/myExample1_asap.dot
