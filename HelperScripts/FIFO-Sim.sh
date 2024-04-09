#!/usr/bin/env sh

loadBar "0.2" "FIFO Sim Loading: "
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
	if [ "$count" = 1 ]; then
		centerText "FIRST IN was $(echo $queue | cut -d',' -f$count)" "R" "$green"
	elif [ "$count" = "$byteAmount" ]; then
		centerText "LAST IN was $(echo $queue | cut -d',' -f$count)" "R" "$green"
	else
		if [ ${#count} = 1 ]; then
			centerText "Byte 0$count is $(echo $queue | cut -d',' -f$count)" "R" "$purple"
		else
			centerText "Byte $count is $(echo $queue | cut -d',' -f$count)" "R" "$purple"
		fi
	fi
done

echo ""; centerText "Done! Press enter to exit back to menu" "Q" "1"; read -r
