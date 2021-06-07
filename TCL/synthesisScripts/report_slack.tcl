#!/usr/bin/tclsh

#REDIRECT: for making a report
#DEPENDENCES: get_all_cells, get_cell_attributes
#retrieve a distribution of cells whose slack falls in a given window

proc get_slack_distribution {slack_start slack_end} {
	set partition 50
	set deltaT [expr {($slack_end - $slack_start)/($partition*1.0)}]
	if {$deltaT <= 0} {
		puts "slack_start < slack_end"
		return 1
	}
	set cells [get_all_cells]
	for {set i 0} {$i<$partition} {incr i} {	
		set distribution($i) 0
		set slack_intervals($i) 0
	}
	foreach cell [get_all_cells] {
		set slack [lindex [get_cell_attributes $cell] end]
		for {set i 0} {$i<$partition} {incr i} {
			set slack_intervals($i) [expr {$i*$deltaT+$slack_start}] 
			if {$slack>=$slack_intervals($i) && $slack< [expr {($i+1)*$deltaT+$slack_start}]} {
			set distribution($i) [expr {$distribution($i) + 1}]
			break
			}
		}
	}
	set ret [list]
	
	puts "SLACK_TSTART,#CELLS"
	for {set i 0} {$i<$partition} {incr i} {	
		lappend ret "$distribution($i)"
		puts "$slack_intervals($i),$distribution($i)"
	}
	#return $ret 
}
