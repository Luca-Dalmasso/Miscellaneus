#!/bin/bash

#setup synthesys environment
#default path is ~/Desktop/LABx, as result of simulation.sh
DEF_PATH="~/Desktop/LABx"
SIM_PATH="$DEF_PATH/vhdlsim"
SYN_PATH="$DEF_PATH/syn"
SYNOPSYS_SCRPT_FILE=".synopsys_dc.setup"
SETUP_SCRPT_SOURCE="/home/repository/ms/setup/.synopsys_dc.setup"
echo "------------------"
if [ $# -lt 3 ]
then
	echo "I'm using deafult working path $DEF_PATH, you shoud change it!"
	echo "I'm using default sim path $SIM_PATH, you should change it!"
	echo "I'm using default syn path $SYN_PATH, you should change it!"
	echo "For a better usage: $0 working_path/ simulation_path/ synthesys_path/"
fi

if [[ ! -d $1 ]] || [[ ! -d $2 ]] || [[ ! -d $3 ]]
then
	echo "Bad argument/s!"
	exit 1
else
	DEF_PATH="$1"
	SIM_PATH="$2"
	SYN_PATH="$3"
fi

cd "$DEF_PATH"
pwd
echo "copying vhdl files from $2 to $3"

#cp -t target/ --> copy all source files into target directory
find "$2" -maxdepth 1 -type f -name '*.vhd' ! -name 'tb_*.vhd' -exec cp -t "$3" {} +
cd "$3"

for file in $(ls)
do
	echo "----------------"
	cat "$file" | grep AFTER
	sed -i 's/AFTER/;--AFTER/gI' "$file"
	if [ $? -eq 0 ]
	then
		echo "$file processed "
	else
		echo "$file cannot be processed!, check $2 before proceeding to synthesys"
		exit 1
	fi
	cat "$file" | grep AFTER
	echo "----------------"
done

cd "$SYN_PATH"

#test for synopsys script:
if [ ! -f "$SYNOPSYS_SCRPT_FILE" ]
then
	echo "copying $SETUP_SCRPT_SOURCE in $SYN_PATH"
	cp $SETUP_SCRPT_SOURCE $SYN_PATH
	if [ $? -eq 1 ]
	then
		echo "cannot copy, do it manually or you cannot proceed to synthesys!"
		exit 1
	fi
fi

setsynopsys 	#setup environment
mkdir work		#tmp for synthesys
echo "start sintetyzer with design_vision &" 







