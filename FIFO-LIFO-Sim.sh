#!/usr/bin/env sh

#Globals
username=""

#Colours
red="\e[31m"
green="\e[32m"
purple="\e[35m"
cyan="\e[36m"
default="\e[0m"
#printf colour https://stackoverflow.com/a/5412776

#Setup an exit handler function
confirmQuit() {
	trap - INT	#Reset sigint to normal behaviour to allow for unconfirmed exit and normal behavoir on exit
	echo -ne "\nAre you sure you wish to exit? [y/n]: "; read -r leave
	if [ "$leave" = "y" ]; then
		clear
		padTop "1"
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

	printf "$colour"	#Set colour for this bar instance
	termWidth=$(( termWidth-1))
	if [ "$1" = "T" ]; then
		printf "╔"
		while [ $barCounter -lt $termWidth ]; do
			printf "%0.s═" $barCounter
			barCounter=$(( barCounter+1 ))
		done
		printf "╗"
	elif [ "$1" = "B" ]; then
		printf "╚"
		while [ $barCounter -lt $termWidth ]; do
			printf "%0.s═" $barCounter
			barCounter=$(( barCounter+1 ))
		done
		printf "╝"
	elif [ "$1" = "J" ]; then
		printf "╠"
		while [ $barCounter -lt $termWidth ]; do
			printf "%0.s═" $barCounter
			barCounter=$(( barCounter+1 ))
		done
		printf "╣"
	elif [ "$1" = "S" ]; then
		while [ $barCounter -le $((termWidth+1)) ]; do
			printf "%0.s═" $barCounter
			barCounter=$(( barCounter+1 ))
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
	needsPadding=$(( termWidth-${#1} ))
	padding=$(( needsPadding/2 ))
	#https://stackoverflow.com/a/8327481
	if [ $(( termWidth %2 )) -eq 0 ]; then
		text="$1"
	else
		text=" $1"
	fi
	printf "$colour"	#Set colour for this instance
	if [ "$2" = "M" ]; then
		printf "║"; printf "%*s" "$(( padding-1 ))"; printf "$textColour""$text""$colour"; printf "%*s" "$(( padding-1 ))"; printf "║"
	elif [ "$2" = "R" ]; then
		printf "%*s" $padding; printf "$text"; printf "%*s" $padding;
	fi
	echo -e "\033[0m"	#Reset to term default colour
}

padTop(){
	termHeight=$(stty size | cut -d " " -f 1)
	if [ "$1" = "Menu" ]; then
		if [ "$username" = "Admin" ]; then
			needsPadding=$(( termHeight-18 ))
			padding=$(( needsPadding/2 ))
		else
			needsPadding=$(( termHeight-16 ))
			padding=$(( needsPadding/2 ))
		fi

		i=0
		while [ "$i" -le "$padding" ]; do
			echo ""
			i=$(( i+1 ))
		done
	else
		case $1 in		#exit function if non numerics (other than Menu) were passed; https://stackoverflow.com/a/3951175
			''|*[!0-9]*) return ;;
			*) ;;
		esac

		needsPadding=$(( termHeight-$1 ))
		padding=$(( needsPadding/2 ))

		i=0
		while [ "$i" -le "$padding" ]; do
			echo ""
			i=$(( i+1 ))
		done
	fi
}

#Called with nothing
drawMainMenu(){
	padTop "Menu"
	barDraw "T" "$cyan"
	centerText "Hewwo!" "M" "$cyan" "$purple"
	barDraw "J" "$cyan"
	centerText "" "M" "$cyan"
	centerText "1)   Login    " "M" "$cyan" "$purple"
	centerText "2)  FIFO Sim  " "M" "$cyan" "$purple"
	centerText "3)  LIFO Sim  " "M" "$cyan" "$purple"
	if [ "$username" = "Admin" ]; then
		centerText "4) Pass change" "M" "$cyan" "$purple"
		centerText "" "M" "$cyan"
		barDraw "J" "$cyan"
		centerText "" "M" "$cyan"
		centerText "5)   Admin    " "M" "$cyan" "$purple"
	elif [ "$username" != "" ]; then
		centerText "4) Pass Change" "M" "$cyan" "$purple"
	fi
	centerText "" "M" "$cyan"
	barDraw "J" "$cyan"
	centerText "Exit" "M" "$cyan" "$red"
	barDraw "B" "$cyan"
}

drawAdminMenu(){
	padTop "Menu"
	barDraw "T" "$green"
	centerText "Administrative Options" "M" "$green" "$cyan"
	barDraw "J" "$green"
	centerText "" "M" "$green"
	centerText "1)   Create an Account  " "M" "$green" "$cyan"
	centerText "2)   Delete an Account  " "M" "$green" "$cyan"
	centerText "3) Change an Account Pin" "M" "$green" "$cyan"
	centerText "" "M" "$green" "$cyan"
	barDraw "J" "$green"
	centerText "Back" "M" "$green" "$red"
	barDraw "B" "$green"
}

#Menu options
loginHandler(){
	if [ "$username" != "" ]; then
		echo -ne 'You are already logged in, logout? Y/N: '; read -r logout
		if [ "$logout" = "Y" ]; then
			username=""
			clear
			padTop
			centerText "The user has been logged out successfully" "R" "$green" "$green"
			return 0
		else
			echo "Logout cancelled"
			return 0
		fi
	else
		while true; do
			echo -n "Enter username: "; read -r tempUsername
			echo -n "Enter password: "; read -r -s password
			echo -ne "\nSo you wish to attempt to login as: $tempUsername? Y/N: "; read -r loginConfirm
			if [ "$loginConfirm" = "" ] || [ "${#tempUsername}" -eq 0 ]; then
				echo "No input supplied, returning to menu"
				return 0
			fi
			if [ "$loginConfirm" = "Y" ]; then
				if [ "$(cat ./UPP.db | grep -c "$tempUsername")" ]; then
					echo "Username match found, checking password"
					echo "$(cat ./UPP.db | grep "$tempUsername")"
					echo "$(cat ./UPP.db | grep "$tempUsername" | cut -d"," -f3 | tr -d '\t')"
					if [ "$password" = "$(cat ./UPP.db | grep "$tempUsername" | cut -d"," -f3 | tr -d '\t')" ]; then
						username="$tempUsername"
						echo "Welcome $username"
						tempUsername=""
						password=""
						return 1
					else
						echo "Incorrect password, try again"
					fi
				else
					echo "Username not found, try again"
				fi
			else
				echo "Please re-enter username and password when prompted"
			fi
		done
	fi
}
callFIFO(){
	if [ "$username" = "" ]; then
		echo "Please login before trying to run a simulation"
		return 1
	fi
	echo "This will run the FIFO simulation"
}
callLIFO(){
	if [ "$username" = "" ]; then
		echo "Please login before trying to run a simulation"
		return 1
	fi
	echo "This will run the FIFO simulation"
}
passChangeHandler(){
	echo "This will run the password change code only if user is logged in"
}
adminStuffs(){
	if [ "$username" != "Admin" ]; then
		return 1
	fi
	while true; do
	drawAdminMenu
		echo -ne '\nEnter an option: '; read -r adminChoice
		if [ "$adminChoice" = "1" ] || [ "$adminChoice" = "Create" ]; then
			echo "This will run user creation code"
		elif [ "$adminChoice" = "2" ] || [ "$adminChoice" = "Delete" ]; then
			echo "This will run the user deletion code"
		elif [ "$adminChoice" = "3" ] || [ "$adminChoice" = "Change Pin" ]; then
			echo "This will allow for a PIN change"
		elif [ "$adminChoice" = "Back" ]; then
			echo "Returning to main menu"
			sleep 2
			clear
			return 0
		elif [ "$adminChoice" = "Bye" ]; then
			confirmQuit
		else
			echo "Please enter a valid option from the above menu"
		fi
		sleep 2
		clear
	done
}

#Debug output
echo "Term width is: $(stty size | cut -d " " -f 2)"
echo "Term height is: $(stty size | cut -d " " -f 1)"
sleep 2
clear

#Program loop
while true; do
	drawMainMenu
	echo -ne '\nEnter an option: '; read -r menuChoice
	clear	#Ensure there is no residual after entering an option

	if [ "$menuChoice" = "1" ] || [ "$menuChoice" = "Login" ]; then
		loginHandler
	elif [ "$menuChoice" = "2" ] || [ "$menuChoice" = "FIFO Sim" ]; then
		callFIFO
	elif [ "$menuChoice" = "3" ] || [ "$menuChoice" = "LIFO Sim" ]; then
		callLIFO
	elif [ "$menuChoice" = "4" ] || [ "$menuChoice" = "Pass Change" ]; then
		if [ "$username" != "" ]; then
			passChangeHandler
		else
			echo "Please enter a valid option from the menu, or enter Bye to exit at any time"
		fi
	elif [ "$menuChoice" = "5" ] || [ "$menuChoice" = "Admin" ]; then
		if [ "$username" = "Admin" ]; then
			adminStuffs
		else
			echo "Please enter a valid option from the menu, or enter Bye to exit at any time"
		fi
	elif [ "$menuChoice" = "Exit" ] || [ "$menuChoice" = "Bye" ]; then
		confirmQuit
	else
		echo "Please enter a valid option from the menu, or enter Bye to exit at any time"
	fi
	sleep 2
	clear
done
