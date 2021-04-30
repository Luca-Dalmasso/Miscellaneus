#!/usr/bin/tclsh

#script that for each wanted cell, compute the worst case rise and falling time
#between fanin-fanout.

#set of wanted cells:
set W_CELLS {HS65_LS_NAND3X2 HS65_LS_IVX2 HS65_LS_AOI211X13 HS65_LSS_XOR2X12}
#wanted cells regular expression
set W_CELL_REGEXP {(HS65_L[L|S|H]+)_([A-Z]+)(\d*X\d*)}

#regexp for PINS ---> pin(A|B|..)
set W_PIN_REGEXP {(pin\([A-Z]+\))}
#regexp for timing() section
set W_TIMING {\s*timing()}

#regexp for RELATED_PIN-->tells us what is the current path we are analyzing worst cases
set W_REL_PIN {\s*timing_label\s:\s"([A-Z]+)_([A-Z]+)(_*\w*)"}
#regexp for TABLE
set W_TABLE {(\d.\d+),\s(\d.\d+),\s(\d.\d+),\s(\d.\d+),\s(\d.\d+)(,\s\d.\d+)?}
#regexp for FALL_TRANSITION
set W_FALL {\s*fall_transition}
#regexp for RISE_TRANSITION
set W_RISE {\s*rise_transition}
#regexp for cell area
set W_AREA {\s*area\s:\s(\d+\.?\w*)}
#regexp for leakage power
set W_LEAK {\s*cell_leakage_power\s:\s(\d+\.?\w*-?\d*)}

set fd [open "CORE65LPSVT_bc_1.30V_m40C.lib" "r"]
set EOF [gets $fd line]
set TYPE {"FIND_CELL" "FIND_PIN" "FIND_TIMING" "COMPUTE_FALLING" "COMPUTE_RISING" "FIND_CELL_INFO"}
set NEXTSTATE [lindex $TYPE 0]
set consume 1
set founds 0
set worst_fall 0
set worst_rise 0
set found_rising 0
set found_falling 0

while { $EOF >= 0 } {
	if { $NEXTSTATE == [lindex $TYPE 0 ] } {
		#CELL PATTERN
		if { ($founds >= [llength $W_CELLS]) && ($NEXTSTATE == [lindex $TYPE 0]) } {
			puts "all wanted cells have been founded! now terminating.."
			break
		}
		set consume 1
		set match_flag [regexp $W_CELL_REGEXP $line match_line gate_n gate_t gate_io]
		if { $match_flag == 1 } {
			#this line actually is a CELL, but is it a WANTED CELL?
			set index [lsearch $W_CELLS $match_line]
			if { $index > -1 } {
				puts "Found: $match_line"
				incr founds
				set NEXTSTATE [lindex $TYPE 5]
			}
		}
	} elseif { $NEXTSTATE == [lindex $TYPE 5] } {
		#extract area and leakage information
		if { [regexp $W_AREA $line match_line cell_area ] == 1 } {
			puts "Area: $cell_area"
		} elseif {[regexp $W_LEAK $line match_line cell_leakage_power ] == 1} {
			puts "leakage power: $cell_leakage_power"
		} elseif {[regexp $W_PIN_REGEXP $line] == 1 } {
			#we are in pin bound! leave this state
			set consume 0
			set NEXTSTATE [lindex $TYPE 1]
		}
	} elseif { $NEXTSTATE == [lindex $TYPE 1] } {
			#we are in the pin pattern
			set consume 1
			set match_flag [regexp $W_CELL_REGEXP $line]
			if { $match_flag == 1 } {
				#we are exeeding cell bounds, now change state and do not allow further reading
				set NEXTSTATE [lindex $TYPE 0]
				set consume 0
			} else {
				set match_flag [regexp $W_PIN_REGEXP $line match_line pin_n]
				if { $match_flag == 1 } {
					#we are in pin bound
					puts "\tFound PIN: $pin_n"
				} else {
					set match_flag [regexp $W_TIMING $line match_line]
					if { $match_flag == 1 } {
						#we are now in the timing bounds, change state and do not allow further reading
						set NEXTSTATE [lindex $TYPE 2]
						set consume 0
					}
				}
			}
	} elseif { $NEXTSTATE == [lindex $TYPE 2]} {
		#we are in timing domain, there is a timing paragraph for each fanin-fanout path
		#for each path we are looking for worst case rise and falling transition time
		set consume 1
		set match_flag [regexp $W_CELL_REGEXP $line]
		if { $match_flag == 1 } {
			#we are exeeding cell bounds, now change state and do not allow further reading
		  set NEXTSTATE [lindex $TYPE 0]
		  set consume 0
			if { $found_rising == 1 } {
				puts "\t\tWorst case RISING: $worst_rise"
				set found_rising  0
				set worst_rise 0
			}
			if { $found_falling == 1 } {
				puts "\t\tWorst case FALLING: $worst_fall"
				set found_falling 0
				set worst_fall 0
			}
	  } else {
	  	set match_flag [regexp $W_REL_PIN $line match_line from_pin to_pin special]
	  	if { $match_flag == 1} {
	  		puts "\t\tPath $from_pin --> $to_pin $special"
	  	} else {
	  		set match_flag [regexp $W_FALL $line]
	 			if { $match_flag == 1} {
					#we found pattern for falling transition
					set found_falling 1
					set NEXTSTATE [lindex $TYPE 3]
				} else {
					set match_flag [regexp $W_RISE $line]
					if { $match_flag == 1} {
						#we found pattern for rising transition
						set found_rising 1
						set NEXTSTATE [lindex $TYPE 4]
					}
				}
			}
		}
	} elseif { $NEXTSTATE == [lindex $TYPE 3]} {
		#we are IN a falling transition table, now find max
		set match_flag [regexp $W_TABLE $line match_line]
	 	if { $match_flag == 1 } {
	 		regsub -all {,\s*} $match_line , match_line
	 		foreach num [split $match_line ","] {
	 			if { $num > $worst_fall } {
	 				set worst_fall $num
	 			}
	 		}
	 	} else {
			set NEXTSTATE [lindex $TYPE 2]
		}
	} elseif { $NEXTSTATE == [lindex $TYPE 4]} {
		#we are IN a rising transition table, now find max
		set match_flag [regexp $W_TABLE $line match_line]
	 	if { $match_flag == 1 } {
	 		regsub -all {,\s*} $match_line , match_line
	 		foreach num [split $match_line ","] {
	 			if { $num > $worst_rise } {
	 				set worst_rise $num
	 			}
	 		}
	 	} else {
			set NEXTSTATE [lindex $TYPE 2]
		}
	}

	if { $consume == 1 } {
		#proceed reading the file, go to next line!
		set EOF [gets $fd line]
	}
}
