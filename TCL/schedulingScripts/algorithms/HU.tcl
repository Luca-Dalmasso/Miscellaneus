#!/usr/bin/tclsh


#!!script not tested for multiple sinks graph!!

variable distance 0
variable node_priority [list]
variable node_visited [list]


proc depth_visit node {
	set nodeINDEX [lsearch -index 0 $::node_priority $node]
	foreach parent [get_attribute $node parents] {
		set ::distance [expr {$::distance + 1}]
		depth_visit $parent
		set ::distance [expr {$::distance - 1}]
	}
	if {$nodeINDEX == -1} {
		lappend ::node_priority "$node $::distance"
	} else {
		if {$::distance > [lindex [lindex $::node_priority $nodeINDEX] 1]} {
			set ::node_priority [lreplace $::node_priority $nodeINDEX $nodeINDEX "$node $::distance"]
		}
	}
}


proc get_sinks nodes {
	set sinks [list]
	foreach node $nodes {
		if {[llength [get_attribute $node children]] == 0} {
			lappend sinks $node
		}
	}
	return $sinks
}

proc priority_wrapper {nodes} {
	set sinks [get_sinks $nodes]
	foreach sink $sinks {
		set ::distance 0
		depth_visit $sink
	}
}

proc getReadyNodes {scheduled orderedNodes} {
	set ready [list]
	set ready_prio_Ordered [list]
	set dontschedule 0
	foreach node $orderedNodes {
		#mark as ready only if it hasn't been already scheduled and all parents scheduled
		set dontschedule 0 
		if {[lsearch -index 0 $scheduled $node] != -1} {
				set dontschedule 1
		}
		foreach parent [get_attribute $node parents] {
			if {[lsearch -index 0 $scheduled $parent] == -1} {
				set dontschedule 1
				break
			}
		}
		if {$dontschedule == 0 } {
			lappend ready $node
		}
	}
	foreach node $ready {
		lappend ready_prio_Ordered [lindex $::node_priority [lsearch -index 0 $::node_priority $node]]
	}
	return [lsort -index 1 -decreasing $ready_prio_Ordered]
}


proc HUs {resources} {
	set top_order [get_sorted_nodes]
	set schedule [list]
	set index 0
	foreach node $top_order {
		lappend ::node_priority "$node 0"
		lappend ::node_visited "$node 0"
		incr index
	}

	priority_wrapper $top_order
	set length_sched [llength $top_order]
	set ready [list]
	set count 0
	set latency 1
	while {[llength $schedule] < $length_sched} {
		
		set ready [getReadyNodes $schedule $top_order]
		set count 0
		foreach rNODE $ready {
			if { $count < $resources } {
				lappend schedule "[lindex $rNODE 0] $latency"
			}
			incr count
		}
		incr latency
	}
	return $schedule
}







