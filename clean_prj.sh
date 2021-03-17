#!/bin/bash

#script that delete all temporary files created by Modelsim and Synopsis 
#after simulation and synthesis process

#--->REMEMBER TO EXEC THIS SCRIPT BEFORE PUSHING AND COMMITTING<-----

if [ $# -lt 1 ]
then
	echo "usage: $0 /working_dir"
	exit 1
fi

if [ ! -d $1 ]
then
	echo "$1 is not a directory"
	exit 1
fi

#deleting all work/ directories

find $1 -type d -name work -exec rm -r 

