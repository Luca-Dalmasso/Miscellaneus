proc asap {} {

  set node_start_time [list]

  foreach node [get_sorted_nodes] {
    set start_time 1
    foreach parent [get_attribute $node parents] {
	  #retrieve RTL functional unit used by parents, by their operation
      set parent_op [get_attribute $parent operation]
      set fu [get_lib_fu_from_op $parent_op]
	  
	  #retrieve parent's delay by parsing RTL FU
      set parent_delay [get_attribute $fu delay]
      #retrieve parent's start time
      set idx_parent_start [lsearch -index 0 $node_start_time $parent]
      set parent_start_time [lindex [lindex $node_start_time $idx_parent_start] 1]
      
      #node Vi is scheduled at Ti=MAX(parent_end_time)
      set parent_end_time [expr $parent_start_time + $parent_delay]
      if { $parent_end_time > $start_time } {
        set start_time $parent_end_time
      }
    }
    lappend node_start_time "$node $start_time"
  }

  return $node_start_time

}
