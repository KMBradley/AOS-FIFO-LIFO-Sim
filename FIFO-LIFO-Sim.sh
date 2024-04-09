#!/usr/bin/env sh

#Globals
username="Admin"

#Colours
red="\e[31m"
green="\e[32m"
purple="\e[35m"
cyan="\e[36m"
default="\e[0m"
#printf colour https://stackoverflow.com/a/5412776

#Setup an exit handler function
confirmQuit(){
	while true; do
		if [ "$#" -eq 0 ]; then
			echo -e "\nSIGINT CAPTURED, exit menu displayed" >> log.txt
		elif [ "$#" -eq 1 ]; then
			echo -e "\nExit requested from $1; exit menu displayed" >> log.txt
		fi
		#echo -ne "\nAre you sure you wish to exit? [y/n]: "; read -r leave
		padTop 1
		echo -e "\n"; centerText "Are you sure you wish to exit? [y/n]: " "Q" "1"; read -r leave
		if [ "$leave" = "Y" ] || [ "$leave" = "y" ]; then
			clear
			trap - INT	#Reset sigint to normal behaviour to allow for unconfirmed exit and normal behaviour on exit
			padTop "1"
			centerText "Goodbye $username" "R" "$green" "$green"
			#Log footer
			echo -e "\nEND OF RUN\n" >> log.txt
			#Remove lower footer line to cleanup log
			#printf "╠" >> log.txt; printf "%80s" | tr " " "═" >> log.txt; printf "╣\n\n\n" >> log.txt
			sleep 2
			clear
			exit
		elif [ "$leave" = "N" ] || [ "$leave" = "n" ]; then
			clear
			padTop "1"
			centerText "Shortly resuming program from prior prompt..." "R"
			echo -e "Exit cancelled, program resuming\n" >> log.txt
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

#Will echo for now rather than export to file
logger(){
	echo "$#: $@"
	if [ "$#" = 0 ]; then
		echo "Logger, no args"
		echo "Current term is: $(echo $TERM)"
		echo "Current time is: $(date -Iseconds)"
	else
		echo "It has args!"
		echo "This is a test" | tee test.txt
	fi
}

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
			printf "%0.s═" #$barCounter
			barCounter=$(( barCounter+1 ))
		done
		printf "╗"
	elif [ "$1" = "B" ]; then
		printf "╚"
		while [ $barCounter -lt $termWidth ]; do
			printf "%0.s═" #$barCounter
			barCounter=$(( barCounter+1 ))
		done
		printf "╝"
	elif [ "$1" = "J" ]; then
		printf "╠"
		while [ $barCounter -lt $termWidth ]; do
			printf "%0.s═" #$barCounter
			barCounter=$(( barCounter+1 ))
		done
		printf "╣"
	elif [ "$1" = "S" ]; then
		while [ $barCounter -le $((termWidth+1)) ]; do
			printf "%0.s═" #$barCounter
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

#Called with the number of lines of text to show on one screen
padTop(){
	termHeight=$(stty size | cut -d " " -f 1)
	if [ "$1" = "Menu" ]; then
		if [ "$username" = "Admin" ]; then
			needsPadding=$(( termHeight-19 ))
			padding=$(( needsPadding/2 ))
		elif [ "$username" != "" ]; then
			needsPadding=$(( termHeight-16 ))
			padding=$(( needsPadding/2 ))
		else
			needsPadding=$(( termHeight-15 ))
			padding=$(( needsPadding/2 ))
		fi

		local padCount=0
		while [ "$padCount" -le "$padding" ]; do
			echo ""
			padCount=$(( padCount+1 ))
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

#Called with a pause value
loadBar(){
	local count=1
	termWidth=$(stty size | cut -d " " -f 2)
	barScaler=$(( $(( termWidth-20 )) ))
	while [ "$count" -le 20 ]; do
		refresh="$(( count%2 ))"
		if [ "$refresh" -eq 0 ]; then
			clear
			bar=$(printf "$purple"; echo -n "<"; printf "%*s" $(( $(( barScaler/25 ))*count )) | tr " " "-"; echo ">")
			barLen=$(( $(( $(( barScaler/25 ))*count ))+2 ))
			leftGap=$(( $(( termWidth-barLen ))/2 ))
			textSize=$(( "${#2}"+4 ))
			padTop "3"
			printf "%*s" $leftGap; printf "$bar"; echo ""
			printf "$green"; printf "%*s" $(( $(( termWidth-textSize ))/2 )); echo "$2 $(( count*5 ))%"
			printf "%*s" $leftGap; printf "$bar"; echo ""
		fi
		count=$(( count+1 ))
		sleep $1
	done
	clear
	padTop "1"
	centerText "Loading Complete!" "$purple"
	return 0
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

#Apparently this should be here and not in the FIFO/LIFO files
genQueue(){
	if [ "$#" -eq 0 ]; then
		local count=10
	else
		local count=$1
	fi
	byteNo=0

	#Clear simdata file
	rm "simdata_$username.job"
	touch "simdata_$username.job"

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

		if [ "$byteNo" -eq "0" ]; then
			echo -e "Adding $cleanedByte at start of queue \n--FIRST IN--"
			sleep 2
			loadBar "0.1" "Generating..."
		fi
		#Check if byte is already written
		if [ "$(grep -c $cleanedByte simdata_$username.job)" -ne 0 ]; then
			echo "Byte collision, regenning byte $(( $byteNo+1 ))"	#Needs +1 as byteNo is still on prior byte as this collided
		elif [ "$byteNo" -eq "$(( count-1)) " ]; then
			byteNo=$(( $byteNo+1 ))		#Increment by 1 as no collision
			echo -n "$cleanedByte" >> "simdata_$username.job"
		else
			byteNo=$(( $byteNo+1 ))		#Increment by 1 as no collision
			echo -n "$cleanedByte," >> "simdata_$username.job"
		fi
	done
	centerText "Regeneration complete, please press enter to continue" "Q" "0"; read -r
	return 0
}

#Menu options
loginHandler(){
	if [ "$username" != "" ]; then
		#echo -n 'You are already logged in, logout? Y/N: '; read -r logout
		padTop 1
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
			centerText "Enter username: " "Q" "5"; read -r tempUsername
			if [ "$tempUsername" = "Bye" ]; then	#Check for exit intent
				confirmQuit "LOGIN"
			fi
			centerText "Enter password: " "R"; read -r -s password
			if [ "$tempPassword" = "Bye" ]; then	#Check for exit intent
				confirmQuit "LOGIN"
			fi
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

							#Ask about regenning sim data
							clear
							padTop 3
							centerText "Do you wish to regen your simdata? Y/N: " "Q" "1"; read -r regenQueue
							if [ "$regenQueue" = "Y" ] || [ "$regenQueue" = "y" ]; then
								centerText "How many bytes do you want to generate? (Default 10): " "Q" "2"; read -r queueSize
								if [ "$queueSize" = "" ] || [[ "$queueSize" =~ [^0-9] ]]; then
									queueSize=10
								fi
								genQueue "$queueSize"
							else
								centerText "Skipping simdata regen..." "R"
							fi

							return 0			#Exit back to menu on successful login
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
			elif [ "$loginConfirm" = "N" ] || [ "$loginConfirm" = "n" ]; then
				centerText "Please re-enter username and password when prompted" "R"
			elif [ "$loginConfirm" = "Bye" ]; then			#Check for exit intent
				confirmQuit "LOGIN"
			else
				centerText "Unknown option, please try again"
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
	while true; do
		padTop "3"
		centerText "Password change" "R" "$green"
		centerText "Please enter the username you wish to change the password for: " "Q" "5"; read -r tempUsername
		if [ "$tempUsername" = "Bye" ]; then	#Check for exit intent
			confirmQuit "PASS-CHANGE"
		fi
		centerText "Please enter the pin for user $tempUsername: " "Q" "3"; read -r -s checkPin
		if [ "$checkPin" = "Bye" ]; then	#Check for exit intent
			confirmQuit "PASS-CHANGE"
		fi

		#Check entered info
		if [ "$(cat ./UPP.db | grep "$tempUsername" | cut -d"," -f2 | tr -d '\t')" = "$tempUsername" ]; then
			echo "Username match found, checking account status"
			if [ $(cat ./UPP.db | grep "$tempUsername" | cut -d"," -f5 | tr -d '\t') = "ACTIVE" ]; then
				echo "User is set as active, checking pin"
				if [ "$checkPin" = "$(cat ./UPP.db | grep "$tempUsername" | cut -d"," -f4 | tr -d '\t')" ]; then
					echo "Pin match"
				else
					centerText "Pin does not match, please try again" "R" "$red"
					sleep 2
					clear
					return 1
				fi
			else
				centerText "User is marked as inactive, please contact the administrator" "R" "$purple"
				sleep 2
				clear
				return 1
			fi
		else
			centerText "Username not found, please try again" "R" "$purple"
			sleep 2
			clear
			return 1
		fi

		#At this point, we know the username is valid and active, and that the user entered the correct pin
		clear
		padTop "6"
		centerText "Details confirmed" "R" "$green"
		centerText "Please enter the new password for user $tempUsername: " "Q" "1"; read -rs newPassword; echo ""
		if [ "$newPassword" = "Bye" ]; then				#Check for exit intent
			confirmQuit "PASS-CHANGE"
		fi
		centerText "Please confirm the new password: " "Q" "1"; read -rs confirmPassword
		if [ "$confirmPassword" = "Bye" ]; then			#Check for exit intent
			confirmQuit "PASS-CHANGE"
		fi

		if [ "${#newPassword}" -ne 5 ] || [ "${#confirmPassword}" -ne 5 ]; then
			centerText "The supplied password did not meet password standards (5 characters long)" "R" "$red"
			centerText "Please try again" "R" "$purple"
			sleep 2
			clear
			return 1
		#Explanation for most of this segment can be found in ./HelperScripts/AdminStuffs.sh -> delAccount, or in commit 7ef8bc7 lines 143-157
		elif [[ "$newPassword" =~ [^0-9a-zA-Z] ]] || [[ "$confirmPassword" =~ [^0-9a-zA-Z] ]]; then
			centerText "The supplied password did not meet password standards (alphanumeric only)" "R" "$red"
			centerText "Please try again" "R" "$purple"
			sleep 2
			clear
			return 1
		elif [ "$newPassword" = "$confirmPassword" ]; then
			#I could assume the account is active, but in the future this function may reactivate accounts, so better to check than to assume
			accountStatus=$(cat ./UPP.db | grep "$tempUsername" | cut -d"," -f5 | tr -d '\t')

			targetID=$(cat ./UPP.db | grep "$tempUsername" | cut -d"," -f1 | tr -d '\t')
			targetLine=$(( targetID+2 ))
			oldLine=$(cat ./UPP.db | grep "$tempUsername")

			#Manually build the line as I cannot find an easy way to substitute one var for another without sed
			newLine="$targetID,\t$tempUsername,\t$confirmPassword,\t$checkPin,\t$accountStatus"

			linesBefore=$(( targetLine-1 ))
			linesAfter=$(( $(wc -l UPP.db | cut -d" " -f1)-$targetLine ))

			mv UPP.db UPP.db.bak
			echo "$(head -n $linesBefore UPP.db.bak)" > UPP.db
			echo -e "$newLine" >> UPP.db
			echo "$(tail -n $linesAfter UPP.db.bak)" >> UPP.db
			rm UPP.db.bak

			echo -e "\n"; centerText "Password changed successfully" "R" "$green"
			centerText "Returning to menu in two seconds"
			sleep 2
			return 0
		else
			centerText "Passwords did not match; Please try again" "R" "$red"
			sleep 2
			clear
			return 1
		fi
	done
}
adminStuffs(){
	if [ "$username" != "Admin" ]; then									#Reject nonAdmin accounts
		return 1
	fi
	while true; do
		#Draw admin menu
		padTop "Menu"
		barDraw "T" "$green"
		centerText "Administrative Options" "M" "$green" "$cyan"
		barDraw "J" "$green"
		centerText "" "M" "$green"
		centerText "1)   Create an Account  " "M" "$green" "$cyan"
		centerText "2)   Delete an Account  " "M" "$green" "$cyan"
		#centerText "3) Change an Account Pin" "M" "$green" "$cyan"		#Pins should be consistent, removed
		centerText "" "M" "$green" "$cyan"
		barDraw "J" "$green"
		centerText "Back" "M" "$green" "$red"
		barDraw "B" "$green"

		echo -ne '\nEnter an option: '; read -r adminChoice				#Prompt for option
		. ./HelperScripts/AdminStuffs.sh								#Source the Admin file for functions

		#Check input
		if [ "$adminChoice" = "1" ] || [ "$adminChoice" = "Create" ]; then
			makeAccount
		elif [ "$adminChoice" = "2" ] || [ "$adminChoice" = "Delete" ]; then
			deleteAccount
		#elif [ "$adminChoice" = "3" ] || [ "$adminChoice" = "Change Pin" ]; then
		#	echo "This will allow for a PIN change"
		elif [ "$adminChoice" = "Back" ]; then
			echo "Returning to main menu"
			sleep 2
			clear
			return 0
		elif [ "$adminChoice" = "Bye" ] || [ "$adminChoice" = "bye" ]; then
			confirmQuit "ADMIN-MENU"
		else
			echo "Please enter a valid option from the above menu"
		fi
		sleep 2
		clear
	done
}

#Start Program
#Debug output
#echo "Term width is: $(stty size | cut -d " " -f 2)"
#echo "Term height is: $(stty size | cut -d " " -f 1)"
#sleep 2
clear

#Logfile header, Middle printf bit from: https://stackoverflow.com/a/5349796
printf "╠" >> log.txt; printf "%80s" | tr " " "═" >> log.txt; printf "╣" >> log.txt
echo -e "\nNEW RUN start for terminal: $(echo $TERM) at time: $(date -Iseconds)\n" >> log.txt

#Program loop
while true; do

	drawMainMenu
	echo -ne "\nEnter an option: "; read -r menuChoice
	clear	#Ensure there is no residual after entering an option

	if [ "$username" = "" ]; then
		echo "Unknown user entered $menuChoice on the main menu" >> log.txt
	else
		echo "User $username entered $menuChoice on the main menu" >> log.txt
	fi

	if [ "$menuChoice" = "1" ] || [ "$menuChoice" = "Login" ]; then
		loginHandler
	elif [ "$menuChoice" = "2" ] || [ "$menuChoice" = "FIFO Sim" ]; then
		callFIFO
	elif [ "$menuChoice" = "3" ] || [ "$menuChoice" = "LIFO Sim" ]; then
		callLIFO
	elif [ "$menuChoice" = "4" ] || [ "$menuChoice" = "Pass Change" ]; then
		#Anyone should be able to call for a password change
		passChangeHandler
	elif [ "$menuChoice" = "5" ] || [ "$menuChoice" = "Admin" ]; then
		if [ "$username" = "Admin" ]; then
			adminStuffs
		else
			echo "Please enter a valid option from the menu, or enter Bye to exit at any time"
			echo "Unauthorized user attempted to access the admin menu" >> log.txt
			sleep 2
		fi
	elif [ "$menuChoice" = "6" ] || [ "$menuChoice" = "FuncTest" ]; then
		echo "Function testing mode"
		logger
	elif [ "$menuChoice" = "Exit" ] || [ "$menuChoice" = "Bye" ] || [ "$menuChoice" = "bye" ]; then
		confirmQuit "MENU"
	else
		echo "Please enter a valid option from the menu, or enter Bye to exit at any time"
		sleep 2
	fi
	clear
done
