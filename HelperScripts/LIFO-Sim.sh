#!/usr/bin/env sh

loadBar "0.2" "LIFO Sim Loading: "
local queue="$(cat simdata_$username.job)"
echo "Queue to work with: $queue"

local byteAmount=$(( $(( ${#queue}+1))/4 ))
echo "Queue size: $byteAmount"
read -r

clear
#Only center vertically if there is enough space to
if [ $(stty size | cut -d " " -f 1) -gt $(( byteAmount+4 )) ]; then
	padTop 12
fi

local count=0
while [ "$count" -lt "$byteAmount" ]; do
	local count=$(( count+1 ))
	local byteNo=$(( $(( byteAmount-count ))+1))
	if [ "$count" = 1 ]; then
		centerText "LAST IN was $(echo $queue | cut -d',' -f$byteNo)" "R" "$green"
	elif [ "$count" = "$byteAmount" ]; then
		centerText "FIRST IN was $(echo $queue | cut -d',' -f$byteNo)" "R" "$green"
	else
		if [ ${#byteNo} = 1 ]; then
			centerText "Byte 0$byteNo is $(echo $queue | cut -d',' -f$byteNo)" "R" "$purple"
		else
			centerText "Byte $byteNo is $(echo $queue | cut -d',' -f$byteNo)" "R" "$purple"
		fi
	fi
done

echo ""; centerText "Done! Press enter to exit back to menu" "Q" "1"; read -r
