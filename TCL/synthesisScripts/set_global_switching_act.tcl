#!/usr/bin/tclsh

#for a sinthetized design, set the switching activity of each net
#by reading a post synthesis gate-level simulation
#NB: it's possible that not all nets are going to be annotated correcty, that's because there's a bad
#    mapping between PrimeTime's nomenclature and ModelSim nomenclature!
#    see the report file 'report_annotated_swt_act.txt'

source /space/s281316/WORK_SYNTHESIS/myScripts/c_statprob_tcount.tcl
set report_file "/space/s281316/WORK_SYNTHESIS/myScripts/report/report_annotated_swt_act.txt"
set sw_act [get_info]
if {[lindex $sw_act] == 0} {
	puts "something wrong while parsing simulation file"
	exit
}
set tcount 0
set period [lindex [lindex $sw_act 0] end ]
foreach item $sw_act {
	set cell [lindex $item 0]
	set mapped_cell ""
	#1) first mapping function: substitute all () into []
	#   [\(\)]
	set mapped_cell [regsub "\\(" $cell {[} ]
	set mapped_cell [regsub "\\)" $mapped_cell {]} ]
	#puts $mapped_cell
	set tcount [lindex $item 1]
	set sprob [lindex $item 2 ]
	if { [ catch {set cell [get_nets $mapped_cell]} ] != 0 } {
		#puts "Warning: No net object is macthing $cell"
	} else {
		if { [lindex $cell] > 0 } {
			#puts "setting for $cell $tcount $period $sprob"
			set_switching_activity $cell -toggle_rate $tcount -period $period \
			-static_probability $sprob
		}
	}
}


