#!/usr/bin/tclsh

#extracts teh list of cells belonging to the most critical paths

set paths [get_timing_paths]
foreach_in_collection timing_point [get_attribute $paths points] {
	set cell_name [get_attribute [get_attribute $timing_point object] full_name]
	set arrival [get_attribute $timing_point arrival]
	puts "$cell_name --> $arrival"
}
