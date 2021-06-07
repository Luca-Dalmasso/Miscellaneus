#!/usr/bin/tclsh

#scripts that analyze a post synthesis gate lavel simulation power report switching actovity
#for each and every net retrieves:
#1) net name
#2) toggle count
#3) static probability
#4) period of the gate level simulation
	
proc get_info {} {
	set fd [open "/space/s281316/WORK_SYNTHESIS/myScripts/aes_cipher_top_swa.txt" "r"]
	set count 0
	set EOF [gets $fd line]
	set myList {}
	while { $EOF >= 0 } {
		if { $count == 2 } {
			set period $line
		} elseif {$count >= 6} {
			set splitted [regexp -inline -all -- {\S+} $line]
			if { [llength $splitted] <= 5} {
				break
			} 
			set net_path [lindex $splitted 0]
			set toggle_count [lindex $splitted 1]
			set at1 [lindex $splitted 3]
			set static_prob [expr {($at1*1.0)/$period}]
			lappend myList "[lindex [split $net_path "/"] end] $toggle_count $static_prob $period"
		}
		set EOF [gets $fd line]
		incr count
	}
	
	close $fd
	#puts "net	togglecount	staticprob"
	#foreach item $myList {
	#	puts "[lindex $item 0]		[lindex $item 1]		[lindex $item 2]"
	#}
	return $myList
}
