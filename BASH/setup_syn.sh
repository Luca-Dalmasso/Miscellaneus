#!/bin/bash

#setup synthesys environment
#default path is ~/Desktop/LABx, as result of simulation.sh
DEF_PATH="/home/$(whoami)/Desktop/LABx"
SIM_PATH="$DEF_PATH/vhdlsim"
SYN_PATH="$DEF_PATH/syn"
SYNOPSYS_SCRPT_FILE=".synopsys_dc.setup"
SETUP_SCRPT_SOURCE="/home/repository/ms/setup/.synopsys_dc.setup"
echo "------------------"
if [ $# -lt 1 ]
then
	echo "I'm using deafult working path $DEF_PATH, you shoud change it!"
	echo "For a better usage: $0 working_path/"
fi

if [ $# -eq 1 ]
then
    if [ ! -d $1 ]
    then
	echo "Bad argument"
	exit 1
    else
	DEF_PATH="$1"
	SIM_PATH="$DEF_PATH/vhdlsim"
	SYN_PATH="$DEF_PATH/syn"
	if [[ ! -d $SIM_PATH ]] || [[ ! -d $SYN_PATH ]] 
	then
		echo "Cannot find ./syn or ./vhdlsim in $DEF_PATH"
		exit 1
	fi
    fi
fi

echo $DEF_PATH
cd $DEF_PATH
pwd
echo "copying vhdl files from $SIM_PATH to $SYN_PATH"

#cp -t target/ --> copy all source files into target directory
find "$SIM_PATH" -maxdepth 1 -type f -name '*.vhd' ! -name 'tb_*.vhd' -exec cp -t "$SYN_PATH" {} +
cd $SYN_PATH

for file in $(ls)
do
	echo "----------------"
	cat "$file" | grep "AFTER"
	sed -i 's/AFTER/;--AFTER/gI' "$file"
	if [ $? -eq 0 ]
	then
		echo "$file processed "
	else
		echo "$file cannot be processed!"
		exit 1
	fi
	cat "$file" | grep "AFTER"
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

mkdir work
echo "start sintetyzer with setsynopsys and  design_vision &" 









