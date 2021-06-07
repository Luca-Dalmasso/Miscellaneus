#!/usr/bin/tclsh

#IMPORTANT: before running this you should run: 'report_threshold_voltage_group' 
#IN: list of cells
#OUT: list of {mapped cell name (ref_name), Threashold voltage group}

proc get_mapping {cells} {
	set cell_GTh [list]
	foreach item $cells {
		set cell [get_cell $item]
		set name [get_attribute $cell ref_name] 
		set group [get_attribute [get_lib_cell -of_object $cell] threshold_voltage_group]
		lappend cell_GTh "$name $group"
	}
	return $cell_GTh
}

