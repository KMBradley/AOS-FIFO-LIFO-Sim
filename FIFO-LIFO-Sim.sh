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

#Setup an exit handler function
confirmQuit() {
	trap - SIGINT	#Reset sigint to normal behaviour
	echo -ne "\nAre you sure you wish to exit? [y/n]: "; read -r leave
	if [ "$leave" = "y" ]; then
		clear
		centerText "Goodbye $username" "R" "$green" "$green"
		sleep 2
		clear
		exit
	else
		echo "Shortly resuming program from prior prompt..."
		trap "confirmQuit" INT
		sleep 2
		return
	fi
}

#Override SIGINT to do our bidding; https://stackoverflow.com/a/14702379
trap "confirmQuit" INT

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

#Called with nothing
drawMenu(){
	barDraw "T" $cyan
	centerText "Hewwo!" "M" $cyan $purple
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
}

#Menu options
loginHandler(){
	echo "This will run the login code"
}
callFIFO(){
	if [ "$username" == "" ]; then
		echo "Please login before trying to run a simulation"
		return
	fi
	echo "This will run the FIFO simulation"
}
callLIFO(){
	if [ "$username" == "" ]; then
		echo "Please login before trying to run a simulation"
		return
	fi
	echo "This will run the FIFO simulation"
}
passChangeHandler(){
	if [ "$username" != "" ]; then
		echo "This will run the password change code only if user is logged in"
	fi
}
adminStuffs(){
	if [ "$username" == "Admin" ]; then
		echo "This will run the admin utilites if the current user is logged in as admin"
	fi
}

#Debug output
echo "Term width is: $(stty size | cut -d " " -f 2)"
echo "Term height is: $(stty size | cut -d " " -f 1)"

#Program loop
while true; do
	drawMenu
	echo -ne '\nEnter an option: '; read -r menuChoice

	if [ "$menuChoice" == "1" ]; then
		loginHandler
	elif [ "$menuChoice" == "2" ]; then
		callFIFO
	elif [ "$menuChoice" == "3" ]; then
		callLIFO
	elif [ "$menuChoice" == "4" ]; then
		if [ "$username" != "" ]; then
			passChangeHandler
		else
			echo "Please enter a valid option from the menu, or enter Bye to exit at any time"
		fi
	elif [ "$menuChoice" == "5" ]; then
		if [ "$username" == "Admin" ]; then
			adminStuffs
		else
			echo "Please enter a valid option from the menu, or enter Bye to exit at any time"
		fi
	elif [ "$menuChoice" == "Exit" ] || [ "$menuChoice" == "Bye" ]; then
		confirmQuit
	else
		echo "Please enter a valid option from the menu, or enter Bye to exit at any time"
	fi
	sleep 2
	clear
done
