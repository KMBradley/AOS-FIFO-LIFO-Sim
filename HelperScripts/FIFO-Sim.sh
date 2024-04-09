#!/usr/bin/env sh

#echo "FIFO Addon File called!"

runFIFO(){

	while true; do
		#echo -n "Load FIFO?"; read -r start
		#if [ "$start" = "y" ]; then
		loadBar "0.3" "FIFO Sim Loading: " "18"
		#else
		#	return 0
		#fi
		queue="$(cat simdata_$username.job)"
		read -r temp
	done
}

#genQueue 10
#runFIFO
