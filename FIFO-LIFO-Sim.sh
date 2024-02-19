#!/usr/bin/env sh

barDraw(){
	barCounter=1
	termWidth=$(stty size | cut -d " " -f 2)
	while [ $barCounter -lt $termWidth ]; do
		printf "%0.s─" $barCounter
		barCounter=$(( $barCounter+1 ))
	done
}

barDraw
echo ""
