#!/usr/bin/env sh

#Globals

#Colours
red="\e[31m"
green="\e[32m"
blue="\e[34m"
purple="\e[35m"
cyan="\e[36m"
#printf colour https://stackoverflow.com/a/5412776


barDraw(){
	barCounter=1
	termWidth=$(stty size | cut -d " " -f 2)
	if [ $1 = "T" ]; then
		termWidth=$(( $termWidth-1))
		printf "╔"
		while [ $barCounter -lt $termWidth ]; do
			printf "%0.s═" $barCounter
			barCounter=$(( $barCounter+1 ))
		done
		printf "╗"
		echo
	elif [ $1 = "B" ]; then
		termWidth=$(( $termWidth-1))
		printf "╚"
		while [ $barCounter -lt $termWidth ]; do
			printf "%0.s═" $barCounter
			barCounter=$(( $barCounter+1 ))
		done
		printf "╝"
		echo
	elif [ $1 = "S" ]; then
		while [ $barCounter -ne $((termWidth+1)) ]; do
			printf "%0.s═" $barCounter
			barCounter=$(( $barCounter+1 ))
		done
		echo
	fi
}

centerMenuText(){
#https://unix.stackexchange.com/a/669693
	termWidth=$(stty size | cut -d " " -f 2)
	stringWidth=$(echo "$1" | wc -m)
	needsPadding=$(( $termWidth-$stringWidth ))
	padding=$(( $needsPadding/2 ))
	printf "║"; printf "%*s" "$padding"; printf $1; printf "%*s" "$padding"; printf "║"; echo
}

barDraw "T"
centerMenuText "Hewwo!"
barDraw "B"
barDraw "S"
echo
