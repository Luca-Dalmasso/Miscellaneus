#!/usr/bin/tclsh

#for a loaded design, returns all cells mapped

proc get_all_cells {} {
	set cells [list]
	foreach_in_collection cell [get_cells] {
		lappend cells [get_attribute $cell full_name]
	}	
	return $cells
}
