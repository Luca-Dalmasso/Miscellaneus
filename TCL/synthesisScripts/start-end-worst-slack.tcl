#!/usr/bin/tclsh

#reports the startpoint name, endpoint name worst case path's slack

proc print {string1 string2 string3} {
	echo [format "%-20s %-20s %s" $string1 $string2 $string3]
}


print "FROM" "TO" "SLACK"
echo "------------------------------------------"
foreach_in_collection path [get_timing_paths] {
	set slack [get_attribute $path slack]
	set startpoint [get_attribute [get_attribute $path startpoint] full_name]
	set endpoint [get_attribute [get_attribute $path endpoint] full_name]
	print $startpoint $endpoint $slack
}
