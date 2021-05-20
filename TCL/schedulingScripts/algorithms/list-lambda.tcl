#!/usr/bin/tclsh

proc get_resources {nodes} {
	set resources [list]
	foreach node $nodes {
		set res [get_attribute $node operation]
		if { [lsearch -index 0 $resources $res] == -1 } {
			set resources [lappend resources "$res 1"]
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
		#	puts "NODE [get_attribute $node label] terminated @$Tcurrent"
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

proc getALAPsched {lambdaAlap lambdaASAP} {
	set ALAPsched [alap $lambdaAlap $lambdaASAP]
	if {$ALAPsched == ""} {
		puts "Since ALAP failed, LIST scheduling cannot proceed!"
		exit
	}
	return $ALAPsched
}

proc computeSLACK {CANDIDATE ALAPsched Tcurrent} {
	set slack 0
	set nodeIndex [lsearch -index 0 $ALAPsched $CANDIDATE]
	if {$nodeIndex < 0} {
		puts "Node cannot be found!"
		exit
	}
	set nodeTime [lindex [lindex $ALAPsched $nodeIndex] 1]
	set slack [expr {$nodeTime - $Tcurrent}]
	#puts "@Time = $Tcurrent [get_attribute $CANDIDATE label]'s slack = $slack"
	return $slack
}

proc updateRes {RES_LIMIT RESOURCES} {
	set RES_LIMIT_INDEX [lsearch -index 0 $RESOURCES [lindex $RES_LIMIT 0]]
	set CURRENT_LIMIT [lindex $RES_LIMIT 1]
	set CURRENT_RES [lindex $RES_LIMIT 0]
	incr CURRENT_LIMIT
	set RES_LIMIT "$CURRENT_RES $CURRENT_LIMIT"
	return [lappend RES_LIMIT $RES_LIMIT_INDEX]
}

proc updateResCount {in_progress operation} {
	set count 0
	foreach llist $in_progress {
		if {[get_attribute [lindex $llist 0] operation]==$operation} {
			incr count
		}
	}
	return $count
}

proc list_sched_timing {lambda_alap lambda_asap} {
	set dfg [get_sorted_nodes]
	set resources [get_resources $dfg]
	set scheduled [list]
	set in_progress [list]
	set candidates [list]
	set Tcurrent 0
	set current_count 0
	set ALAPsched [getALAPsched $lambda_alap $lambda_asap]

	while {[llength $scheduled] != [llength $dfg]} {
		incr Tcurrent
		set in_progress [update_in_progress $in_progress $scheduled $Tcurrent]
		foreach RES_LIMIT $resources {
			set current_count [updateResCount $in_progress [lindex $RES_LIMIT 0]]
			foreach CAND [get_candidates $in_progress $scheduled $dfg] {
				set RES_TYPE [get_attribute $CAND operation]
				if { $RES_TYPE == [lindex $RES_LIMIT 0] } {
					if {[computeSLACK $CAND $ALAPsched $Tcurrent] == 0} {
						lappend scheduled "$CAND $Tcurrent"
						lappend in_progress "$CAND $Tcurrent [get_attribute [get_lib_fu_from_op $RES_TYPE] delay]"
						#puts "[get_attribute $CAND label] is now scheduled at TIME= $Tcurrent"
						incr current_count
						if {$current_count > [lindex $RES_LIMIT 1] } {
							set TMP [updateRes $RES_LIMIT $resources]
							set RES [lindex $TMP 0]
							set LIMIT [lindex $TMP 1]
							set RES_LIMIT "$RES $LIMIT"
							set resources [lreplace $resources [lindex $TMP 2] [lindex $TMP 2] $RES_LIMIT]
							#puts "TMP: $TMP, RES_LIMIT=$RES_LIMIT, resources=$resources"
						}
					}
				}
			}
			#process remaining unscheduled nodes with slack positive
			foreach CAND [get_candidates $in_progress $scheduled $dfg] {
				set RES_TYPE [get_attribute $CAND operation]
				if { $RES_TYPE == [lindex $RES_LIMIT 0] } {
					if {$current_count < [lindex $RES_LIMIT 1]} {
						lappend scheduled "$CAND $Tcurrent"
						lappend in_progress "$CAND $Tcurrent [get_attribute [get_lib_fu_from_op $RES_TYPE] delay]"
						#puts "[get_attribute $CAND label] is now scheduled at TIME= $Tcurrent"
						incr current_count
					}
				} 
			}
			#puts "IN PROGRESS: $in_progress"
		}
	}
	return $scheduled
}







