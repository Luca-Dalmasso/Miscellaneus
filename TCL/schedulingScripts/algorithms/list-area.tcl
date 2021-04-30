#!/usr/bin/tclsh



proc get_resources {nodes} {
	set resources [list]
	foreach node $nodes {
		set res [get_attribute $node operation]
		if { [lsearch $resources $res] == -1 } {
			lappend resources $res
		}
	}
	return $resources
}

# receives a list with (OP,BOUND), (OP,BOUND)
# just check congruency 
proc set_res_bounds {resources bounds} {
	foreach ITEM $bounds {
		set OP [lindex $ITEM 0]
		set NUM [lindex $ITEM 1]
		set index [lsearch $resources $OP]
		if { $index > -1 } {
			set resources [lreplace $resources $index $index "$OP $NUM"]
		} else {
			puts "Resource type $OP is not performed by any node in the dfg!"
			exit
		}
	}
	return $resources
}

# modify IN PROGESS nodes
# IN_PROGRESS: (NODE Tstart NodeLatency)
proc update_in_progress {in_progress nodes_to_update Tcurrent} {
	
	foreach node $nodes_to_update {
		set index_in_progress [lsearch -index 0 $in_progress [lindex $node 0]]
		if {$index_in_progress == -1} {
			continue
		}
		set item [lindex $in_progress $index_in_progress]
		set deltaT [ expr {$Tcurrent - [lindex $item 1]} ]
 		set lambda [lindex $item 2]
		if { $deltaT == $lambda } {
			#puts "NODE [get_attribute $node label] terminated @$Tcurrent"
			set in_progress [lreplace $in_progress $index_in_progress $index_in_progress]
		}
	}
	return $in_progress
}

# starting from dfg, creates list of struct type:
# NODE
# a CANDIDATE is choosen only if none of his parents (or himself) has already been scheduled or still in progress

proc get_candidates {in_progress scheduled dfg} {
	
	set ready [list]
	set dontschedule 0
	foreach node $dfg {
		#mark as ready only if it hasn't been already scheduled and all parents scheduled and not in process
		set dontschedule 0 
		if {[lsearch -index 0 $scheduled $node] != -1} {
				set dontschedule 1
		}
		foreach parent [get_attribute $node parents] {
			if {[lsearch -index 0 $scheduled $parent] == -1} {
				set dontschedule 1
				break
			}
			foreach still_running $in_progress {
				if {[lsearch -index 0 $in_progress $parent] != -1 } {
					set dontschedule 1
					break
				}
			}
		}	
		if {$dontschedule == 0 } {
			lappend ready $node
		}
	}
	return $ready
}

proc list_sched_area {input_bounds} {

	set dfg [get_sorted_nodes]
	set resources [get_resources $dfg]
	#set input_bounds {"MUL 1" "ADD 2" "DIV 1"}
	set resources [set_res_bounds $resources $input_bounds]
	#puts $resources
	set test_progress [list]
	set scheduled [list]
	set in_progress [list]
	set candidates [list]
	set Tcurrent 0
	set current_count 0
	while {[llength $scheduled] != [llength $dfg] } {
		incr Tcurrent
		set in_progress [update_in_progress $in_progress $scheduled $Tcurrent]
		foreach RES_LIMIT $resources {
			set current_count 0
			foreach CAND [get_candidates $in_progress $scheduled $dfg] {
				set RES_TYPE [get_attribute $CAND operation]
				if { $RES_TYPE == [lindex $RES_LIMIT 0] & $current_count < [lindex $RES_LIMIT 1]} {
					incr current_count
					lappend scheduled "$CAND $Tcurrent"
					lappend in_progress "$CAND $Tcurrent [get_attribute [get_lib_fu_from_op $RES_TYPE] delay]"
					#puts "[get_attribute $CAND label] is now scheduled at TIME= $Tcurrent"
				}
			}
			#puts "IN PROGRESS: $in_progress"
		}
	}
	return $scheduled
}







