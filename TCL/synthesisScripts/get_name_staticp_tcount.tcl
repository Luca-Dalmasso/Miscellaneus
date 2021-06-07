#!/usr/bin/tclsh

#for a loaded design, it retrieves 3 lists containing:
#1) net_list: nets full_name
#2) static_probability_list: nets static_probabillirty
#3) toggle_count_list: nets toggle_count

set net_list {}
set stat_list {}
set tcount_list {}

foreach net [get_nets] {
	lappend net_list [get_attribute $net full_name]
	lappend stat_list [get_attribute $net static_probability]
	lappend tcount_list [get_attribute $net toggle_count]
}

return  "$net_list $stat_list $tcount_list"
