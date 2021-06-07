#!/usr/bin/tclsh

variable distance 0
variable node_visited [list]
variable tmp_path [list]
variable critical_path [list]
variable greedy_list_delay [list]

#given a loaded design (as a DFG data type)
#performs a analyshis of the graph looking for the critical path
#it returns a list of nodes rapresenting the critical path


#$node == sink node
proc depth_visit_get_critical node {
	set nodeINDEX [lsearch -index 0 $::node_visited $node]
	set ::node_visited [lreplace $::node_visited $nodeINDEX $nodeINDEX "$node 1"]
	foreach parent [get_attribute $node parents] {
		set has_visited [lindex [lindex $::node_visited [lsearch -index 0 $::node_visited $parent]] 1]
		if {$has_visited == 0} {
			set ::distance [expr {$::distance + [get_delay [get_attribute $node operation]]}]
			lappend ::tmp_path "$node $::distance"
			if {[llength [get_attribute $parent parents]] == 0} {
				set ::distance [expr {$::distance + [get_delay [get_attribute $parent operation]]}]
				lappend ::tmp_path "$parent $::distance"
			}
			depth_visit_get_critical $parent
			if {[llength [get_attribute $parent parents]] == 0} {
				set ::distance [expr {$::distance - [get_delay [get_attribute $parent operation]]}]
				set prev_index [expr {[llength $::tmp_path] - 1}] 
				set ::tmp_path [lreplace $::tmp_path $prev_index $prev_index]
			}
			set ::distance [expr {$::distance - [get_delay [get_attribute $node operation]]}]
			set prev_index [expr {[llength $::tmp_path] - 1}] 
			set ::tmp_path [lreplace $::tmp_path $prev_index $prev_index]
		}
	}
	
	if {$::distance > [lindex [lindex $::critical_path end] 1]} {
		set ::critical_path $::tmp_path
	}
}

#for a given node's operation, retrieve the max delay
#operation==node's operation
#greedy_list_delay==functional units ordered by delay
#exmple of a possible greedy_list_delay:
#LOD {{L12 10 5} {L11 20 2} {L10 40 1}}, MUL {{L6 40 10} {L5 70 5} {L4 100 2}}
#generic format: LIST of ITEMS where ITEM is a LIST--> OP {{FU AREA DELAY} {..} ...}

proc get_delay {operation} {
	set index [lsearch -index 0 $::greedy_list_delay $operation]
	if {$index == -1} {
		puts "On get_delay(), $operation not found in greedy_list.."
		exit
	}
	return [lindex [lindex [lindex [lindex $::greedy_list_delay $index] 1] 0] 2]
}

#get all sink nodes for a given DFG
#nodes == DFG
proc get_sinks nodes {
	set sinks [list]
	foreach node $nodes {
		if {[llength [get_attribute $node children]] == 0} {
			lappend sinks $node
		}
	}
	return $sinks
}

#wrapper for depth_visit_get_critical
#nodes == DFG
proc depth_visit_wrapper {nodes} {
	set sinks [get_sinks $nodes]
	foreach sink $sinks {
		set ::distance 0
		depth_visit_get_critical $sink
	}
}

proc get_critical_path {} {
	lappend ::greedy_list_delay "MUL {{L6 40 10} {L5 70 5} {L4 100 2}}"
	lappend ::greedy_list_delay "ADD {{L2 10 5} {L1 20 2} {L0 40 1}}"
	lappend ::greedy_list_delay "LOD {{L12 10 5} {L11 20 2} {L10 40 1}}"
	lappend ::greedy_list_delay "STR {{L15 10 5} {L14 20 2} {L13 40 1}}"

	set top_order [get_sorted_nodes]
	set index 0
	foreach node $top_order {
		lappend ::node_visited "$node 0"
		incr index
	}

	depth_visit_wrapper $top_order

	puts "NODE, DISTANCE FROM SINK"
	foreach item $::critical_path {
		puts "[get_attribute [lindex $item 0] label] [lindex $item 1]"
	}
	
	return $::critical_path
}

