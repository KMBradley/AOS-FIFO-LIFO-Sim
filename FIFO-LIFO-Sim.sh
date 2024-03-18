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
	while true; do
		#echo -ne "\nAre you sure you wish to exit? [y/n]: "; read -r leave
		echo -e "\n"; centerText "Are you sure you wish to exit? [y/n]: " "Q" "1"; read -r leave
		if [ "$leave" = "Y" ] || [ "$leave" = "y" ]; then
			clear
			padTop "1"
			centerText "Goodbye $username" "R" "$green" "$green"
			sleep 2
			clear
			exit
		elif [ "$leave" = "N" ] || [ "$leave" = "n" ]; then
			clear
			padTop "1"
			centerText "Shortly resuming program from prior prompt..." "R"
			trap "confirmQuit" INT
			sleep 2
			return
		else
			centerText "Please enter Y/N to continue..." "R"
		fi
	done
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
	if [ $# -eq 3 ] && [ ${#3} -gt 2 ]; then
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
		echo -e "\033[0m"	#Reset to term default colour
	elif [ "$2" = "R" ]; then
		printf "%*s" $padding; printf "$text"; printf "%*s" $padding;
		echo -e "\033[0m"	#Reset to term default colour
	elif [ "$2" = "Q" ]; then
		if [ "$(( padding %2 ))" -eq 1 ]; then
			padding=$(( padding-(($3+1)/2) ))
		else
			padding=$(( padding-($3/2) ))
		fi
		printf "%*s" $padding; printf "$text"		#Skip end padding so question is inline correctly
	fi
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
	centerText "4) Pass Change" "M" "$cyan" "$purple"
	if [ "$username" = "Admin" ]; then
		centerText "" "M" "$cyan"
		barDraw "J" "$cyan"
		centerText "" "M" "$cyan"
		centerText "5)   Admin    " "M" "$cyan" "$purple"
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
	#centerText "3) Change an Account Pin" "M" "$green" "$cyan"
	centerText "" "M" "$green" "$cyan"
	barDraw "J" "$green"
	centerText "Back" "M" "$green" "$red"
	barDraw "B" "$green"
}

#Menu options
loginHandler(){
	if [ "$username" != "" ]; then
		#echo -n 'You are already logged in, logout? Y/N: '; read -r logout
		centerText "You are already logged in, logout? Y/N: " "Q" "1"; read -r logout
		if [ "$logout" = "Y" ] || [ "$logout" = "Y" ]; then
			username=""
			clear
			padTop "1"
			centerText "The user has been logged out successfully" "R" "$green" "$green"
			return 0
		else
			echo "Logout cancelled"
			return 0
		fi
	else
		while true; do
			padTop "5"
			#echo -n "Enter username: "; read -r tempUsername
			#echo -n "Enter password: "; read -r -s password
			centerText "Enter username: " "Q" "5"; read -r tempUsername
			centerText "Enter password: " "R"; read -r -s password
			#echo -ne "\nSo you wish to attempt to login as: $tempUsername? Y/N: "; read -r loginConfirm
			echo -e "\n"; centerText "So you wish to attempt to login as: $tempUsername? Y/N: " "Q" "1"; read -r loginConfirm
			if [ "$loginConfirm" = "" ] || [ "${#tempUsername}" -eq 0 ]; then
				echo "No input supplied, returning to menu"
				return 0
			fi
			if [ "$loginConfirm" = "Y" ] || [ "$loginConfirm" = "y" ]; then
				#if [ "$(cat ./UPP.db | grep -c "$tempUsername" -ne 0 | cut -d"," -f3 | tr -d '\t')" = "" ]; then		#Allowed people to login pass only
				if [ "$(cat ./UPP.db | grep "$tempUsername" | cut -d"," -f2 | tr -d '\t')" = "$tempUsername" ]; then	#Fixes above issue
					echo "Username match found, checking account status"
					if [ $(cat ./UPP.db | grep "$tempUsername" | cut -d"," -f5 | tr -d '\t') = "ACTIVE" ]; then
						echo -e "User is set as active, checking password\n"
						if [ "$password" = "$(cat ./UPP.db | grep "$tempUsername" | cut -d"," -f3 | tr -d '\t')" ]; then
							username="$tempUsername"
							centerText "Welcome $username" "R"
							tempUsername=""
							password=""
							return 1			#Exit back to menu on successful login
						else
							echo "Incorrect password, try again";
						fi
					else
						echo "Account is marked is inactive, please contact the administrator";
						return 1
					fi
				else
					echo "Username not found, try again";
				fi
			else
				echo "Please re-enter username and password when prompted"
			fi
			sleep 5			#Pause for 5 seconds to allow user to read error message
			clear
		done
	fi
}
callFIFO(){
	if [ "$username" = "" ]; then
		echo "Please login before trying to run a simulation"
		return 1
	fi
	echo "This will run the FIFO simulation"
	. ./HelperScripts/FIFO-Sim.sh		#Source the FIFO-Sim file for functions
}
callLIFO(){
	if [ "$username" = "" ]; then
		echo "Please login before trying to run a simulation"
		return 1
	fi
	echo "This will run the LIFO simulation"
	. ./HelperScripts/LIFO-Sim.sh		#Source the LIFO-Sim file for functions
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
		. ./HelperScripts/AdminStuffs.sh	#Source the Admin file for functions
		if [ "$adminChoice" = "1" ] || [ "$adminChoice" = "Create" ]; then
			makeAccount
		elif [ "$adminChoice" = "2" ] || [ "$adminChoice" = "Delete" ]; then
			echo "This will run the user deletion code"
		#elif [ "$adminChoice" = "3" ] || [ "$adminChoice" = "Change Pin" ]; then
		#	echo "This will allow for a PIN change"
		elif [ "$adminChoice" = "Back" ]; then
			echo "Returning to main menu"
			sleep 2
			clear
			return 0
		elif [ "$adminChoice" = "Bye" ] || [ "$adminChoice" = "bye" ]; then
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
	elif [ "$menuChoice" = "Exit" ] || [ "$menuChoice" = "Bye" ] || [ "$menuChoice" = "bye" ]; then
		confirmQuit
	else
		echo "Please enter a valid option from the menu, or enter Bye to exit at any time"
	fi
	sleep 2
	clear
done
