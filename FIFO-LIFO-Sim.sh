#!/usr/bin/env sh

barDraw(){
	barCounter=1
	termWidth=$(stty size | cut -d " " -f 2)
	while [ $barCounter -lt $termWidth ]; do
		printf "%0.s─" $barCounter
		barCounter=$(( $barCounter+1 ))
	done
}

centerMenuText(){
	termWidth=$(stty size | cut -d " " -f 2)
	stringWidth=$(echo "$1" | wc -m)
	needsPadding=$(( $termWidth-$stringWidth ))
	padding=$(( $needsPadding/2 ))
	printf "|"; printf "%*s" "$padding"; printf $1; printf "%*s" "$(( $padding-1))"; printf "|"; echo
}

barDraw
echo
centerMenuText "Hewwo!"

