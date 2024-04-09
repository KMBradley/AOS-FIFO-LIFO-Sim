#!/usr/bin/env sh

#echo "FIFO Addon File called!"


#echo -n "Load FIFO?"; read -r start
#if [ "$start" = "y" ]; then
loadBar "0.2" "FIFO Sim Loading: " "18"
#else
#	return 0
#fi
queue="$(cat simdata_$username.job)"
echo $queue
read -r temp


#genQueue 10
#runFIFO
