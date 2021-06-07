#!/usr/bin/tclsh

#command used to swap a set of cells from HVT-->LVT or viceversa
#IN: list of cells, type (=LVT or HVT)
#OUT: true=1, false=0. use the report_threshold_voltage command to see the difference

proc swap_voltage {cells type} {
	set LVT "CORE65LPLVT_nom_1.20V_25C.db:CORE65LPLVT/"
	set HVT "CORE65LPHVT_nom_1.20V_25C.db:CORE65LPHVT/"
	if {$type!="HVT" && $type!="LVT"} {
		puts "type: $type must be HVT or LVT"
		return 0
	}
	foreach cell_name $cells {
		set cell [get_cell $cell_name]
		set refName [get_attribute $cell ref_name]
		#if i want to substitute a HVT with LVT i just need to substitute the 'LH'
		#in the cell refName with 'LL', viceversa for the LVT->HVT substitution
		if {$type=="LVT"} {
			set refName [regsub -all {_LH} $refName {_LL}]
			size_cell $cell "$LVT$refName" 
		} else {
			set refName [regsub -all {_LL} $refName {_LH}]
			size_cell $cell "$HVT$refName"
		} 
	}
}
