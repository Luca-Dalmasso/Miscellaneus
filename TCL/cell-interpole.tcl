#!/usr/bin/tclsh

proc load_lut_header { IN_PIN IN_CELL } {
	set founds 0
	set consume 0
	set fd [open "CORE65LPSVT_bc_1.30V_m40C.lib" "r"]
	set EOF [gets $fd line]
	set states {"FIND_CELL" "FIND_PIN" "FIND_TIMING" "LOAD_HEADER" "LOAD_TABLE"}
	set NEXTSTATE [lindex $states 0]
	set ret [list]
	set header ""
	#REGEXP
	set W_CELL_REGEXP {(HS65_L[L|S|H]+)_([A-Z]+)(\d*X\d*)}
	set W_TIMING {\s*timing()}
	set W_REL_PIN {\s*timing_label\s:\s"([A-Z]+)_([A-Z]+)(_*\w*)"}
  set W_CELL_FALL {\s+cell_fall\((\w+)\)}
	set W_TABLE {(\d.\d+),\s(\d.\d+),\s(\d.\d+),\s(\d.\d+),\s(\d.\d+)(,\s\d.\d+)?}

	while { $EOF >= 0 } {
			if {$NEXTSTATE == [lindex $states 0]} {
				#looking for wanted cell
				set consume 1
				set match_flag [regexp $W_CELL_REGEXP $line match_line gate_n gate_t gate_io]
				if { $match_flag == 1 } {
					#this line actually is a CELL, but is it a WANTED CELL?
					if { $match_line == $IN_CELL } {
						puts "Found: $match_line"
						incr founds
						set NEXTSTATE [lindex $states 1]
					}
				}
			} elseif {$NEXTSTATE == [lindex $states 1]} {
				#looking for timing label
				set match_flag [regexp $W_TIMING $line match_line]
				if { $match_flag == 1 } {
					set NEXTSTATE [lindex $states 2]
				}
			} elseif {$NEXTSTATE == [lindex $states 2]} {
				#looking for timing label related to IN_PIN
				set match_flag [regexp $W_REL_PIN $line match_line from_pin to_pin]
		  	if { $match_flag == 1} {
					if { $from_pin == $IN_PIN } {
						#we found our path
						puts "Path: $from_pin->$to_pin"
						set NEXTSTATE [lindex $states 3]
					}
 		  	}
			} elseif {$NEXTSTATE == [lindex $states 3]} {
				#extract cell_table header
				set match_flag [regexp $W_CELL_FALL $line match_line tmp ]
	 			if { $match_flag == 1} {
					#we found pattern for cell falling
					set header $tmp
					set NEXTSTATE [lindex $states 4]
				}
			} elseif {$NEXTSTATE == [lindex $states 4]} {
				#extract cell_table
				set match_flag [regexp $W_TABLE $line match_line]
			 	if { $match_flag == 1 } {
			 		regsub -all {,\s*} $match_line , match_line
					lappend table [split $match_line ","]
			 	} else {
					#we done with this cell, we can exit
					break
				}
			}

		if { $consume == 1 } {
			#proceed reading the file, go to next line!
			set EOF [gets $fd line]
		}
	}
	close $fd
	return [lappend ret $header $table ]
}

proc find_imm_pred {lu_table_I in_net} {
	set pred -1
	set index 0
	set pred_tmp [lindex $lu_table_I $index ]
	while { $pred_tmp < $in_net } {
		set pred $pred_tmp
		incr index
		set pred_tmp [lindex $lu_table_I $index ]
	}
	return [lappend ret $pred [expr {$index - 1}] ]
}

proc find_imm_succ {lu_table_I in_net} {
	set succ -1
	set index [expr [llength $lu_table_I] - 1 ]
	set succ_tmp [lindex $lu_table_I $index ]
	while { $succ_tmp > $in_net } {
		set succ $succ_tmp
		set index [expr {$index - 1}]
		set succ_tmp [lindex $lu_table_I $index ]
	}
	return [lappend ret $succ [expr {$index + 1}] ]
}

proc bil_interpole {x1 y1 x2 y2 q11 q12 q21 q22 x y} {
	puts "Bilinear interpolation on ($x,$y) with:"
	puts "x1=$x1 x2=$x2 y1=$y1 y2=$y2 q11=$q11 q12=$q12 q21=$q21 q22=$q22"
	set f_x_y1 [expr {(($x2-$x)/($x2-$x1))*$q11 + (($x-$x1)/($x2-$x1))*$q21}]
	set f_x_y2 [expr {(($x2-$x)/($x2-$x1))*$q12 + (($x-$x1)/($x2-$x1))*$q22}]
	return [expr {(($y2-$y)/($y2-$y1))*$f_x_y1 + (($y-$y1)/($y2-$y1))*$f_x_y2}]
}

proc setup_interpole {pred_t_row succ_t_row pred_c_col succ_c_col table input_t output_c} {
		#check if there are all 4 points
		set x1 [ lindex $pred_t_row 0 ]
		set x2 [ lindex $succ_t_row 0 ]
		set y1 [ lindex $pred_c_col 0 ]
		set y2 [ lindex $succ_c_col 0 ]
		if { ($x1 == -1)||($x2 == -1)||($y1 == -1)||($y2 == -1)} {
			puts "Bilinear interpolation is not feasible with current inputs"
			exit -1
		}
		set q11 [extract_element $table [lindex $pred_t_row 1] [lindex $pred_c_col 1]]
		set q12 [extract_element $table [lindex $pred_t_row 1] [lindex $succ_c_col 1]]
		set q21 [extract_element $table [lindex $succ_t_row 1] [lindex $pred_c_col 1]]
		set q22 [extract_element $table [lindex $succ_t_row 1] [lindex $succ_c_col 1]]
		return [bil_interpole $x1 $y1 $x2 $y2 $q11 $q12 $q21 $q22 $input_t $output_c]
}

proc extract_element {table index_row index_col} {
	return [ lindex [lindex $table $index_row] $index_col]
}

proc find_lut_header {table_name} {
	set fd [open "CORE65LPSVT_bc_1.30V_m40C.lib" "r"]
	set states {"FIND_HEAD" "FIND_TAB"}
	set NEXTSTATE [lindex $states 0]
	set EOF [gets $fd line]
	#regexp for LUT_TABLE 'index_1(" 0.005, 0.02, 0.041, 0.083, 0.17, 0.33 ");'
	set W_TAB {\s*index_\d\("\s*(.*)\s"\);}
	set LUT_TABLE [list]
	while { $EOF >= 0 } {
		if { $NEXTSTATE == [lindex $states 0] } {
			set match_flag [regexp {(\s*lu_table_template\(table_10\))} $line match_line ]
			if { $match_flag == 1} {
				puts "Found LUT header: $match_line"
				set NEXTSTATE [lindex $states 1]
			}
		} elseif { $NEXTSTATE == [lindex $states 1] } {
			set match_flag [regexp $W_TAB $line match_line array ]
			if { $match_flag == 1} {
				puts "$array"
				regsub -all {,\s*} $array , array
				lappend table [split $array ","]
			} else {
				break
			}
		}
		set EOF [gets $fd line]
	}
	close $fd
	return $table
}


set in_pin "B"
set in_cell "HS65_LS_NAND2X2"
set in_net_transition 0.025
set out_net_cap 0.010
set myRET [load_lut_header $in_pin $in_cell]
foreach row [lindex $myRET 1] {
	foreach col $row {
		puts -nonewline "$col "
	}
	puts ""
}

set table [ find_lut_header [lindex $myRET 0] ]
set lu_tab_I1_test [lindex $table 0]
set lu_tab_I2_test [lindex $table 1]
set pred_t_row [find_imm_pred $lu_tab_I1_test $in_net_transition]
set succ_t_row [find_imm_succ $lu_tab_I1_test $in_net_transition]
set pred_c_col [find_imm_pred $lu_tab_I2_test $out_net_cap]
set succ_c_col [find_imm_succ $lu_tab_I2_test $out_net_cap]
set result [setup_interpole $pred_t_row $succ_t_row $pred_c_col $succ_c_col \
					  [lindex $myRET 1] $in_net_transition $out_net_cap]
puts "Interpolation result: $result"
