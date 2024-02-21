#!/usr/bin/env sh

#Globals
username="Admin"

#Colours
red="\e[31m"
green="\e[32m"
blue="\e[34m"
purple="\e[35m"
cyan="\e[36m"
default="\e[0m"
#printf colour https://stackoverflow.com/a/5412776

#Called with Type, Optionally colour
barDraw(){
	barCounter=1
	termWidth=$(stty size | cut -d " " -f 2)
	if [ $# -eq 2 ]; then
		colour=$2
	else
		colour=$default
	fi

	printf $colour	#Set colour for this bar instance
	termWidth=$(( $termWidth-1))
	if [ $1 = "T" ]; then
		printf "╔"
		while [ $barCounter -lt $termWidth ]; do
			printf "%0.s═" $barCounter
			barCounter=$(( $barCounter+1 ))
		done
		printf "╗"
	elif [ $1 = "B" ]; then
		printf "╚"
		while [ $barCounter -lt $termWidth ]; do
			printf "%0.s═" $barCounter
			barCounter=$(( $barCounter+1 ))
		done
		printf "╝"
	elif [ $1 = "J" ]; then
		printf "╠"
		while [ $barCounter -lt $termWidth ]; do
			printf "%0.s═" $barCounter
			barCounter=$(( $barCounter+1 ))
		done
		printf "╣"
	elif [ $1 = "S" ]; then
		while [ $barCounter -le $((termWidth+1)) ]; do
			printf "%0.s═" $barCounter
			barCounter=$(( $barCounter+1 ))
		done
		printf ""
	fi
	echo -e "\033[0m"	#Reset to term default colour
}

#Called with: Text, Type, Optionally border colour and text colour
centerText(){
	if [ $# -eq 3 ]; then
		colour=$3
	elif [ $# -eq 4 ]; then
		colour=$3
		textColour=$4
	else
		colour=$default
		textColour=$default
	fi
	#https://unix.stackexchange.com/a/669693
	termWidth=$(stty size | cut -d " " -f 2)
	stringWidth=$(echo "$1" | wc -m)
	needsPadding=$(( $termWidth-$stringWidth ))
	padding=$(( $needsPadding/2 ))
	#https://stackoverflow.com/a/8327481
	if [ `expr $termWidth % 2` -eq 0 ]; then
		text="$1 "
	else
		text="$1"
	fi
	printf $colour	#Set colour for this instance
	if [ $2 = "M" ]; then
		printf "║"; printf "%*s" "$padding"; printf $textColour"$text"$colour; printf "%*s" "$(( padding-1 ))"; printf "║"
	elif [ $2 = "R" ]; then
		printf "%*s" $padding; printf "$text"; printf "%*s" $padding;
	fi
	echo -e "\033[0m"	#Reset to term default colour
}

barDraw "T" $cyan
centerText "Hewwo!" "M" $cyan
barDraw "J" $cyan
centerText "" "M" $cyan
centerText "1)   Login    " "M" $cyan $purple
centerText "2)  FIFO Sim  " "M" $cyan $purple
centerText "3)  LIFO Sim  " "M" $cyan $purple
if [ "$username" == "Admin" ]; then
	centerText "4) Pass change" "M" $cyan $purple
	centerText "" "M" $cyan
	barDraw "J" $cyan
	centerText "" "M" $cyan
	centerText "5)   Admin    " "M" $cyan $purple
elif [ "$username" != "" ]; then
	centerText "4) Pass change" "M" $cyan $purple
fi
centerText "" "M" $cyan
barDraw "J" $cyan
centerText "Exit" "M" $cyan $red
barDraw "B" $cyan

echo "$(stty size | cut -d " " -f 2)"
