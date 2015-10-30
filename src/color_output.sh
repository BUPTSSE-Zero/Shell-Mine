#!/bin/bash
BLACK=30
RED=31
GREEN=32
ORANGE=33
BLUE=34
PURPLE=35
SBLUE=36
GREY=37

fore_ground=""
back_ground=""

case $2 in
	black)
		fore_ground=${BLACK}
		;;
	red)
		fore_ground=${RED}
		;;
	green)
		fore_ground=${GREEN}
		;;
	orange)
		fore_ground=${ORANGE}
		;;
	blue)
		fore_ground=${BLUE}
		;;
	purple)
		fore_ground=${PURPLE}
		;;
	sblue)
		fore_ground=${SBLUE}
		;;
	grey)
		fore_ground=${GREY}
		;;
esac

case $3 in
	black)
		back_ground=$((${BLACK}+10))
		;;
	red)
		back_ground=$((${RED}+10))
		;;
	green)
		back_ground=$((${GREEN}+10))
		;;
	orange)
		back_ground=$((${ORANGE}+10))
		;;
	blue)
		back_ground=$((${BLUE}+10))
		;;
	purple)
		back_ground=$((${PURPLE}+10))
		;;
	sblue)
		back_ground=$((${SBLUE}+10))
		;;
	grey)
		back_ground=$((${GREY}+10))
		;;
esac

if [ "$fore_ground" == "" ]; then
	echo -ne "$1"
elif [ "$back_ground" == "" ]; then
	echo -ne "\e[${fore_ground}m$1\e[39m"
else
	echo -ne "\e[${fore_ground};${back_ground}m$1\e[39;49m"
fi

