#!/bin/bash

OK=0
TRUE=0
FALSE=1
ANSI_PRIFIX="\033["

row_total=0
col_total=0
mine_num=0
grid_has_mine=""
grid_checked=""
grid_mine_num_surround=""
grid_total_num=0
current_cur_row=0
current_cur_col=0
temp_row=0
temp_col=0
temp_index=0

function stty_init()
{
	stty_save=$(stty -g) 	#备份当前终端设置
	clear					#清屏
	trap "game_exit;" 2 15	#当程序收到SIGINT(2)和SIGTERM(15)信号时调用game_exit()函数后再终止程序
	stty -echo				#禁用字符输入回显，也就是输入的所有字符都不会被显示出来

	echo -ne "${ANSI_PRIFIX}?25l" 	#隐藏光标
 	return $OK
}

function game_exit()
{
	stty $stty_save			#恢复原来的终端设置
	stty echo				#恢复字符输入回显
	clear
	trap 2 15
	echo -ne "${ANSI_PRIFIX}?25h${ANSI_PRIFIX}0m"			#恢复光标显示和其他所有属性（包括前景色和背景色等）

	exit $OK
}

function index_to_row_col()
{
	if [ $(($1%$col_total)) -eq 0 ]; then
		temp_row=$(($1/$col_total))
		temp_col=$col_total
	else
		temp_row=$(($1/$col_total+1))
		temp_col=$(($1%$col_total))
	fi
}

function row_col_to_index()
{
	temp_index=$((($1-1)*col_total+$2))
}

function next_surround_row_col()
{
	case $1 in
		1)
			temp_row=$(($temp_row-1))
			temp_col=$(($temp_col-1))
			;;
		[23])
			temp_col=$(($temp_col+1))
			;;
		[45])
			temp_row=$(($temp_row+1))
			;;
		[67])
			temp_col=$(($temp_col-1))
			;;
		8)
			temp_row=$(($temp_row-1))
			;;
	esac
}

function check_row_col()
{
	if [ $1 -lt 1 ]; then
		return $FALSE
	elif [ $1 -gt $row_total ]; then
		return $FALSE
	elif [ $2 -lt 1 ]; then
		return $FALSE
	elif [ $2 -gt $col_total ]; then
		return $FALSE
	else
		return $TRUE
	fi
}

function init_game()
{
	for i in $(seq 1 $grid_total_num)
	do
		grid_has_mine[$i]=$FALSE
		grid_checked[$i]=$FALSE
		grid_mine_num_surround[$i]=0
	done
	local temp
	for (( i=1; i<=$mine_num; i=i+1))
	do
		temp=$(($RANDOM%$grid_total_num+1))		#RANDOM为系统环境变量
		#echo "random=${temp}"
		if [ ${grid_has_mine[$temp]} -eq $FALSE ]; then
			grid_has_mine[$temp]=$TRUE
		else
			#echo "This grid already has a mine."
			i=$(($i-1))		
		fi
	done
	for i in $(seq 1 $grid_total_num)
	do
		index_to_row_col $i
		for j in $(seq 1 8)
		do
			next_surround_row_col $j
			check_row_col $temp_row $temp_col
			if [ $? -eq $TRUE ]; then
				row_col_to_index $temp_row $temp_col
				#echo "temp index=${temp_index}"
				if [ ${grid_has_mine[$temp_index]} -eq $TRUE ]; then
					grid_mine_num_surround[$i]=$((${grid_mine_num_surround[$i]}+1))
				fi
			fi
		done
		#echo "The grid $i has ${grid_mine_num_surround[$i]} mine."
	done
}

function menu_select()
{
	local key
	while [ true ]
	do
		read -s -n 1 key
		case $key in
		1)
			row_total=10
			col_total=10
			grid_total_num=100
			mine_num=7
			clear
			bash ./game_interface.sh $row_total $col_total $mine_num
			return $OK
			;;
		2)
			row_total=14
			col_total=20
			grid_total_num=280
			mine_num=40
			clear
			bash ./game_interface.sh $row_total $col_total $mine_num
			return $OK
			;;
		3)
			row_total=18
			col_total=35
			grid_total_num=630
			mine_num=80
			clear
			bash ./game_interface.sh $row_total $col_total $mine_num
			return $OK
			;;
		4)
			game_exit
			exit 0
			;;
		esac
	done 	
}

function check_cur_row_col()
{
	if [ $1 -lt 2 ]; then
		return $FALSE
	elif [ $1 -gt $(($row_total+1)) ]; then
		return $FALSE
	elif [ $2 -lt 2 ]; then
		return $FALSE
	elif [ $2 -gt $(($col_total*2)) ]; then
		return $FALSE
	else
		return $TRUE
	fi
}

function cur_row_col_to_index()
{
	temp_index=$((($1-2)*col_total+$2/2))
}

function show_color_num()
{
	if [ $2 -eq $TRUE ]; then
		bash ./color_output.sh "$1" grey orange
		return $OK
	fi
	case $1 in
	[12])
		bash ./color_output.sh "$1" green
		;;
	[34])
		bash ./color_output.sh "$1" blue
		;;
	[56])
		bash ./color_output.sh "$1" orange
		;;
	*)
		bash ./color_output.sh "$1" red
		;;
	esac
	return $OK
}

function move_cur()
{
	local next_cur_row
	local next_cur_col
	case $1 in
	up)
		next_cur_row=$(($current_cur_row-1))
		next_cur_col=$current_cur_col
		;;
	right)
		next_cur_row=$current_cur_row
		next_cur_col=$(($current_cur_col+2))
		;;
	down)
		next_cur_row=$(($current_cur_row+1))
		next_cur_col=$current_cur_col
		;;
	left)
		next_cur_row=$current_cur_row
		next_cur_col=$(($current_cur_col-2))
		;;
	esac

	check_cur_row_col $next_cur_row $next_cur_col
	if [ $? -eq $FALSE ]; then
		return $FALSE
	fi

	cur_row_col_to_index $current_cur_row $current_cur_col
	bash ./locate_cursor.sh $current_cur_row $current_cur_col
	if [ ${grid_checked[$temp_index]} -eq $FALSE ]; then
		bash ./color_output.sh "X" sblue
	elif [ ${grid_mine_num_surround[$temp_index]} -eq 0 ]; then
		bash ./color_output.sh " "
	else
		show_color_num ${grid_mine_num_surround[$temp_index]} $FALSE
	fi
	
	current_cur_row=$next_cur_row
	current_cur_col=$next_cur_col
	cur_row_col_to_index $current_cur_row $current_cur_col
	bash ./locate_cursor.sh $current_cur_row $current_cur_col
	if [ ${grid_checked[$temp_index]} -eq $FALSE ]; then
		bash ./color_output.sh "X" sblue orange
	elif [ ${grid_mine_num_surround[$temp_index]} -eq 0 ]; then
		bash ./color_output.sh " " sblue orange
	else
		show_color_num ${grid_mine_num_surround[$temp_index]} $TRUE
	fi
	return $OK
}

function query_replay()
{
	local exit_key
	while [ true ]
	do
		read -s -n 1 exit_key
		case $exit_key in
		[yY])
			exec bash $(dirname $0)/$(basename $0)
			;;
		[nN])
			game_exit
			exit 0
			;;
		esac 
	done
}

function check_win()
{
	for i in $(seq 1 $grid_total_num)
	do
		if [ ${grid_has_mine[$i]} -eq $FALSE -a ${grid_checked[$i]} -eq $FALSE ]; then
			return $FALSE
		elif [ ${grid_has_mine[$i]} -eq $TRUE ]; then
			continue
		fi
	done
	return $TRUE
}

function dfs()
{
	local temp_row2
	local temp_col2
	temp_row=$1
	temp_col=$2
	for i in $(seq 1 8)
	do
		next_surround_row_col $i
		check_row_col $temp_row $temp_col
		if [ $? -eq $TRUE ]; then
			row_col_to_index $temp_row $temp_col
			if [ ${grid_has_mine[$temp_index]} -eq $TRUE ]; then
				continue
			elif [ ${grid_checked[$temp_index]} -eq $TRUE ]; then
				continue
			elif [ ${grid_mine_num_surround[$temp_index]} -eq 0 ]; then
				grid_checked[$temp_index]=$TRUE
				bash ./locate_cursor.sh $(($temp_row+1)) $(($temp_col*2))
				bash ./color_output.sh " "
				temp_row2=$temp_row
				temp_col2=$temp_col
				dfs	$temp_row $temp_col
				temp_row=$temp_row2
				temp_col=$temp_col2
			fi
		fi
	done
}

function dig()
{
	cur_row_col_to_index $current_cur_row $current_cur_col
	if [ ${grid_checked[$temp_index]} -eq $TRUE ]; then
		return $FALSE
	fi
	grid_checked[$temp_index]=$TRUE
	bash ./locate_cursor.sh $current_cur_row $current_cur_col
	if [ ${grid_has_mine[$temp_index]} -eq $TRUE ]; then					#挖到地雷
		bash ./color_output.sh "@" grey red
		read -s -n 1
		bash ./lost_dialog.sh
		query_replay
	elif [ ${grid_mine_num_surround[$temp_index]} -eq 0 ]; then				#周围没有地雷
		bash ./color_output.sh " " sblue orange
		index_to_row_col $temp_index
		dfs $temp_row $temp_col											#使用深度优先搜索算法，从目前坐标出发，找出其它连着的周围雷数为0的格子
		bash ./locate_cursor.sh $current_cur_row $current_cur_col
	else
		show_color_num ${grid_mine_num_surround[$temp_index]} $TRUE
	fi
	check_win
	if [ $? -eq $TRUE ]; then												#玩家赢
		bash ./win_dialog.sh
		query_replay
	fi
	return $OK
}

function main()
{
	menu_select
	current_cur_row=2
	current_cur_col=2
	bash ./locate_cursor.sh $current_cur_row $current_cur_col
	bash ./color_output.sh "X" sblue orange
	init_game
	local key
	while [ true ]
	do
		read -s -n 1 key
		case $key in
		[wW])
			move_cur up
			;;
		[aA])
			move_cur left
			;;
		[sS])
			move_cur down
			;;
		[dD])
			move_cur right
			;;
		[jJ])
			dig
			;;
		[nN])
			exec bash $(dirname $0)/$(basename $0)
			;;
		[xX])
			game_exit
			exit 0
			;;
		esac
	done
}

cd $(dirname $0)
stty_init
bash ./menu.sh
main
game_exit
exit 0

