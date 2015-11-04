#!/bin/bash
bash ./locate_cursor.sh 6 29
 bash ./color_output.sh "You lost!" orange

i=1
line=1
while [ $i -lt 3 ]
do
line=$(($i*10-8))
bash ./locate_cursor.sh $line 15
Counter1=1
until [ $Counter1 -ge 8 ]
  do
   bash ./color_output.sh "*     " green
   Counter1=$(($Counter1+1))
  done
i=$(($i+1))
done

bash ./locate_cursor.sh 5 15
bash ./color_output.sh "*" sblue
bash ./locate_cursor.sh 9 15
bash ./color_output.sh "*" grey
bash ./locate_cursor.sh 5 51
bash ./color_output.sh "*" sblue
bash ./locate_cursor.sh 9 51
bash ./color_output.sh "*" grey

bash ./locate_cursor.sh 17 29
bash ./color_output.sh "game again?" sblue
bash ./locate_cursor.sh 19 31
bash ./color_output.sh "Y--YES" grey
bash ./locate_cursor.sh 21 31
bash ./color_output.sh "N--NO" grey
