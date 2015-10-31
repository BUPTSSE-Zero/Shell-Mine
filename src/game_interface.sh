#!/bin/bash
for i in $(seq 1 $1)
do
	bash ./locate_cursor.sh $(($i+1)) 1
	for j in $(seq 1 $2)
	do
		bash ./color_output.sh "|X" sblue
	done
done

