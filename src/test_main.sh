#!/bin/bash

OK=0
FALSE=1
ANSI_PRIFIX="\033["

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

cd $(dirname $0)
stty_init

#在这里用bash命令来运行shell脚本来测试代码，例如：bash xxx.sh
bash ./color_output.sh "Hello World!\n" grey sblue
bash ./color_output.sh "Hello World!\n" blue
bash ./color_output.sh "Hello World!"
bash ./game_interface.sh 10 10 30
read -s -n 1				#按任意键退出
game_exit
exit 0
