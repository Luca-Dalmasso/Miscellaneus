#!/usr/bin/tclsh

#compute the slack time for each critical paths to the same endpoint.

set maxcovering 2000000

proc print {startpoint endpoint group slack} {
	echo [format "%-25s %-25s %-25s %s" $startpoint $endpoint $group $slack]
}

print "STARTPOINT" "ENDPOINT" "GROUP" "SLACK"
foreach_in_collection group [get_path_groups *] {
	foreach_in_collection path [get_timing_paths -nworst $maxcovering -group $group] {
		set start [get_attribute [get_attribute $path startpoint] full_name]
		set end  [get_attribute [get_attribute $path endpoint] full_name]
		set slack [get_attribute $path slack]
		set group_name [get_attribute $group full_name]
		print $start $end $group_name $slack
	}
}

if {[sizeof_collection $path] == 0} {
	puts "No path with negative slack for setup time :)"
}
