#!/usr/bin/tclsh

#simple library parser based on regular expressions
#we look for a certain WANTED CELL until all WANTED CELLS are found
#if we find a WANTED CELL then we extract all PINS CAPACITANCES
#until all liberty file has been read


#wanted cells is a linked list
set W_CELLS {HS65_LS_NAND3X2 HS65_LS_IVX2 HS65_LS_AOI211X13 HS65_LSS_XOR2X12}
#wanted cell regular expression (all gates we are looking do have the same skeleton..)
#GROUP1: GATE NAME, GROUP2: GATE TYPE, GROUP3: FANIN, FANOUT
set W_CELL_REGEXP {(HS65_L[L|S|H]+)_([A-Z]+)(\d*X\d*)}

#regexp for PINS ---> pin(A|B|..)
set W_PIN_REGEXP {(pin\([A-Z]+\))}
#regexp for pin capacitance
set W_PIN_CAP {\scapacitance\s:\s(\d\.\d+);}

set fd [open "CORE65LPSVT_bc_1.30V_m40C.lib" "r"]
set EOF [gets $fd line]
set NEXTSTATE "FIND_CELL"
set consume 1
set founds 0

while { $EOF >= 0 } {
	#like a FSM
	if { $NEXTSTATE == "FIND_CELL" } {
		set consume 1
		set match_flag [regexp $W_CELL_REGEXP $line match_line gate_n gate_t gate_io]
		if { $match_flag == 1 } {
			#this line actually is a CELL, but is it a WANTED CELL?
			set index [lsearch $W_CELLS $match_line]
			if { $index > -1 } {
				puts "Found: $match_line"
				incr founds
				set NEXTSTATE "FIND_PINS"
			}
		}
	
	} elseif { $NEXTSTATE == "FIND_PINS" } {
		#looking for $gate_n' s pins..
		set consume 1
		#check if we are not exeeding current CELL specifications
		set match_flag [regexp $W_CELL_REGEXP $line]
		if { $match_flag == 1 } {
			#we are exeeding cell bounds, now change state and do not allow further reading
			set NEXTSTATE "FIND_CELL"
			set consume 0
		}
		set match_flag [regexp $W_PIN_REGEXP $line match_line pin_n]
		if { $match_flag == 1 } {
			#we are in pin bound, now time to extract capacitance!
		  puts "--Pin $pin_n"
		}
		set match_flag [ regexp $W_PIN_CAP $line match_line pin_c]
		if { $match_flag == 1 } {
			puts "----capacitance: $pin_c"
		}
	}
	
	if { ($founds >= [llength $W_CELLS]) && ($NEXTSTATE == "FIND_CELL") } {
		puts "all wanted cells have been founded! now terminating.."
		break
	}
	
	if { $consume == 1 } {
		#proceed reading the file, go to next line!
		set EOF [gets $fd line]
	}
} 
