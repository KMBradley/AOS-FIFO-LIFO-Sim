#!/usr/bin/env sh

echo "FIFO Addon File called!"

genQueue(){
	if [ $# -eq 0 ]; then
		count=10
	else
		count=$1
	fi
	byteNo=0
	rawQueue=$(shuf -i0-99 -n $count);
	cleanedQueue="";
	while IFS= read -r byte; do
		byteNo=$(( byteNo+1 ))
		if [ "${#byte}" -eq 1 ] && [ "$byteNo" -ne "$count" ]; then
			cleanedQueue+="B0$byte,"
		elif [ "${#byte}" -eq 2 ] && [ "$byteNo" -ne "$count" ]; then
			cleanedQueue+="B$byte,"
		elif [ "${#byte}" -eq 1 ]; then
			cleanedQueue+="B0$byte"
		elif [ "${#byte}" -eq 2 ]; then
			cleanedQueue+="B$byte"
		fi
	done <<< "$rawQueue";
	echo "$cleanedQueue"
}

genQueue 50
