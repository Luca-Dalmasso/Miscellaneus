#!/usr/bin/tclsh

#DEPENDENCES: ./myScripts/mapping_info.tcl
#IN: cell name ex U300

proc cell_resizing {cell type} {
	set LVT "CORE65LPLVT_nom_1.20V_25C.db:CORE65LPLVT/"
	set HVT "CORE65LPHVT_nom_1.20V_25C.db:CORE65LPHVT/"
	set cell_obj [get_cell $cell]
	set VTH [lindex [lindex [get_mapping $cell] 0] 1]
	set refName ""
	if {$type == "MAX" || $type == "max"} {
		set refName [sub_max $cell_obj] 
	} elseif {$type == "MIN" || $type == "min"} {
		set refName [sub_min $cell_obj]
	} else {
		puts "type $type must be 'MAX' (or 'max) or 'MIN' (or 'min')"
		return 0
	}
	if {$VTH == "LVT"} {
		size_cell $cell_obj "$LVT$refName"
	} elseif {$VTH == "HVT"} {
		size_cell $cell_obj "$HVT$refName"
	} else {
		puts "VTH TYPE $VTH not recognized"
		return 0
	}
	return 1
}



proc sub_max {cell_obj} {
	set max_size 0
	set cell_max_ref_name ""
	foreach bname [get_alternative_lib_cells -current_library -base_names $cell_obj] {
		set match_flag [regexp {X(\d+)} $bname match_line size]
		if {$match_flag == 1} {
			if {$size > $max_size} {
				set max_size $size
				set cell_max_ref_name $bname
			}
		}
	}
	return $cell_max_ref_name
}


proc sub_min {cell_obj} {
	set min_size 0
	set cell_min_ref_name ""
	foreach bname [get_alternative_lib_cells -current_library -base_names $cell_obj] {
		set match_flag [regexp {X(\d+)} $bname match_line size]
		if {$match_flag == 1} {
			if {$min_size == 0} {
				set min_size $size
			} elseif {$size < $min_size}  {
				set min_size $size
				set cell_min_ref_name $bname
			}
		}
	}
	return $cell_min_ref_name
}
