#!/usr/bin/tclsh

#scripts that retrieve all useful attributes from a cell

#proc get_max_slack {cellREF} {
#	set path [get_timing_path -through $cellREF]
#	return [get_attribute $path slack]
#}

proc max {val1 val2} {
	if {$val1 > $val2 } {
		return $val1
	}
	return $val2
}


proc min {val1 val2} {
	if {$val1 < $val2 } {
		return $val1
	}
	return $val2
}


proc get_cell_attributes {cellREF} {
	set cellREF [get_cell $cellREF]
	set attr_list [list]
	if {$cellREF == ""} {
		puts "$cellREF doesn't exists in the current design!"
		return attr_list
	}
	set sizeregexp {\w*X(\d*)}
	#we are interested to get rise_fall of a particular pin
	#set maxrise [get_attribute $cellREF max_rise_arrival]
	#set maxfall [get_attribute $cellREF max_fall_arrival]
	set out_pins [get_pins -of_object $cellREF -filter {direction==out}]
	lappend attr_list [get_attribute $cellREF full_name]
	lappend attr_list [get_attribute $cellREF ref_name]
	lappend attr_list [get_attribute $cellREF area]
	set ref_name [lindex $attr_list 1]
	if {[regexp $sizeregexp $ref_name match_line size] } {
		lappend attr_list $size
	} else {
		lappend attr_list "?"
	}
	lappend attr_list [get_attribute $cellREF leakage_power]
        lappend attr_list [get_attribute $cellREF dynamic_power]
	lappend attr_list [get_attribute $cellREF total_power]
	#lappend attr_list [max $maxrise $maxfall]
	#lappend attr_list [get_attribute $cellREF [get_max_slack $cellREF]
	set max_fall_arrival 0
	set max_rise_arrival 0
	set max_slack 0
	foreach out_pin $out_pins {
		if {$max_fall_arrival==0} {
			set max_fall_arrival [get_attribute $out_pin max_fall_arrival]
		
		} else {
			set max_fall_arrival [max $max_fall_arrival  [get_attribute $out_pin max_fall_arrival]]
		}

		if {$max_rise_arrival==0} {
			set max_rise_arrival [get_attribute $out_pin max_rise_arrival]
		
		} else {
			set max_rise_arrival [max $max_rise_arrival  [get_attribute $out_pin max_rise_arrival]]
		}
		
		if {$max_slack==0} {
			set max_slack [get_attribute $out_pin max_slack]
		} else {
			set max_slack [min $max_slack [get_attribute $out_pin max_slack]]
		}
	}
	lappend attr_list [max $max_rise_arrival $max_fall_arrival]
	lappend attr_list $max_slack
	return $attr_list
}
