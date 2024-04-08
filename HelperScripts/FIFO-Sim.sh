#!/usr/bin/env sh

#echo "FIFO Addon File called!"

genQueue(){
	if [ $# -eq 0 ]; then
		count=10
	else
		count=$1
	fi
	byteNo=0

	while [ "$byteNo" -lt "$count" ]; do
		#Generate the byte
		byte=$(head /dev/urandom | od -An -N1 -d)	#https://linuxsimply.com/bash-scripting-tutorial/operator/arithmetic-operators/random-number/
		byte=$(( $byte % 100 ))						#% 100 was decent advise from a friend for how to constrain the output of od

		#0 pad if needed
		if [ "${#byte}" -eq 1 ]; then
			cleanedByte="B0$byte"
		elif [ "${#byte}" -eq 2 ]; then
			cleanedByte="B$byte"
		fi

		#B00 is invalid, so change to B01
		if [ "$cleanedByte" = "B00" ]; then
			cleanedByte="B01"
		fi

		#Collision check and write
		#Check if file doesn't exist (it shouldn't) then make that new file
		if [ ! -f "simdata_$username.job" ]; then
			byteNo=$(( $byteNo+1 ))		#Increment by 1 as always ran
			echo -n "$cleanedByte," > "simdata_$username.job"
		else
			#Check if byte is already written
			if [ "$(grep -c $cleanedByte simdata_$username.job)" -eq 0 ]; then
				byteNo=$(( $byteNo+1 ))		#Increment by 1 as no collision
				if [ "$byteNo" -lt "$count" ]; then
					echo -n "$cleanedByte," >> "simdata_$username.job"
				else
					echo "$cleanedByte" >> "simdata_$username.job"
				fi
			else
				echo "Byte collision, regenning byte $(( $byteNo+1 ))"
			fi
		fi
	done
	return 0
}

runFIFO(){

	while true; do
		echo -n "Load FIFO?"; read -r start
		if [ "$start" = "y" ]; then
			loadBar "0.3" "FIFO Sim Loading: " "18"
		else
			return 0
		fi
	done
}

#genQueue 10
runFIFO
