# CORE65LPSVT_bc_1.30C_m40C.lib
	- Library for standard cell description and characterization
	- Provided by silicon vendors
	- Process: Best, Voltage: 1.30V, Temperature: -40°C

# libraryScripts
tcl scripts used to explore a standard liberty file (library of stdcells provided by silicon vendor).

## generic-rules.txt
- tcl scripting lenguage in a nutshell
	
## mylib_parser.tcl
- example of a FSM-like library parser

## wc-transitions.tcl
- more complete example of library parser, used to compute worst case rise/falling transition time
	  of a standard cell
	  
## Cell-interpole.tcl
- complete example on how to handle a bilinear interpolation on given cell's propagation time

# schedulingScripts
tcl scripts for computing HLS on a generic circuit rappresented as a dfg (.dot file, not included here)
Algorithms implemented:
- ASAP
- ALAP
- HU's algorithm
- LIST scheduling under area constraints
- LIST scheduling under timing constraints
