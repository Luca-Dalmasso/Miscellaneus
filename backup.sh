#!/bin/bash

#simple script that compress recursively a directory (and all subs)
#in another directory
#required source/ dest/ path by command line.

if [ $# -lt 2 ]
then
	echo "usage: $0 source/ dest/"
	exit 1
fi

if [[ ! -d $1 ]] || [[ ! -d $2 ]]
then
	echo "bad source/ dest/"
	exit 1
fi

for name in $(ls "$1")
do
	zip -r "$2/$name.zip" "$1/$name"
done

exit 1
