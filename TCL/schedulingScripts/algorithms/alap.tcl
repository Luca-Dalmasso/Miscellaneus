proc alap {lambda_start lambda_asap} {
	set empty_schedule [list]
	set schedule [list]
	if {$lambda_start < $lambda_asap} {
		puts "Not possible to have less latency than ASAP!"
		return $empty_schedule
	}
	set reversed_top_order [reversed]
	foreach node [reversed] {
		set Tstart $lambda_start
		set node_op [get_attribute $node operation]
		set node_delay [get_attribute [get_lib_fu_from_op $node_op] delay]
		#find all node's successors (childrens)
		if { [get_attribute $node n_children] == 0 } {
			set Tstart [expr $lambda_start + 1 - $node_delay]
		}
		foreach child [get_attribute $node children] {
			set child_scheduled [lindex $schedule [lsearch -index 0 $schedule $child]]
			set child_sched_time [lindex $child_scheduled 1]
			set Tsched [expr $child_sched_time - $node_delay]
			if {$Tsched < 0} {
				puts "ALAP unfeasible"
				return $empty_schedule
			}
			if {$Tsched < $Tstart} {
				set Tstart $Tsched
			}
		}
		lappend schedule "$node $Tstart"
	}
	return $schedule
}

proc reversed {} {
	set to [get_sorted_nodes]
	set rto [list]
	set length [llength $to]
	for {set index_reversal 0} {$index_reversal<$length} {incr index_reversal} {
		lappend rto [lindex $to [expr $length-$index_reversal-1]]
	} 
	return $rto
}
