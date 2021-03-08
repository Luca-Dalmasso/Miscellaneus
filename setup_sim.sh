#!/bin/bash

#script for setting up a working directory for simulation and synthesys
#default working directory will be ~/Desktop/LAB

DEF_PATH="~/Desktop"
echo "------------------"
echo "Set up a simulation environment"

if [ $# -lt 1 ]
then
	echo "I'm using the default wirking path $DEF_PATH, you should change it!"
	echo "Better usage: <$0> working_path/"
else
	if [ ! -d $1 ]
	then
		echo "$1 is not a correct path!"
		exit 1
	else
		echo "Running as <$0> <$1>"
		echo "New working path is: $1"
		DEF_PATH="$1"
	fi
fi

cd "$DEF_PATH"
mkdir "LABx"

if [ $? -eq 1 ]
then
	echo "Coudn't proceed, sorry!"
	exit 1 
fi

mkdir "LABx/vhdlsim"

if [ $? -eq 1 ]
then
	echo "Coudn't proceed, sorry!"
	exit 1 
fi

mkdir "LABx/syn"

if [ $? -eq 1 ]
then
	echo "Coudn't proceed, sorry!"
	exit 1 
fi

echo "$DEF_PATH"
echo "|"
echo "|--/LABx"
echo "|  |"
echo "|  |--/vhdlsim (*place here vhdl design to simulate)"
echo "|  |--/syn (*where synthesys is done)"
echo "------------------"

#setup simulator
cd "LABx/vhdlsim"
setmentor 	#environment variables for vsim
vlib "work" #temporary folder for simulator

echo "Now you can place VHDL here, simulate with Questa Modelsim. [use vsim &]"





