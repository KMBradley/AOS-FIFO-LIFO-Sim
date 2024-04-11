#!/usr/bin/env sh

#Globals
username=""
startUnix=$(date +%s)
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
		#Will only ever have no args if it is a sigint
		if [ "$#" -eq 0 ]; then
			echo -e "\nSIGINT CAPTURED, exit menu displayed" >> Uasge.db
		elif [ "$#" -eq 1 ]; then
			echo -e "\nExit requested from $1; exit menu displayed" >> Uasge.db
		fi

		clear
		padTop 1
		echo -e "\n"; centerText "Are you sure you wish to exit? [y/n]: " "Q" "1"; read -r leave	#Give the user a chance to cancel
		if [ "$leave" = "Y" ] || [ "$leave" = "y" ]; then
			clear
			trap - INT		#Reset sigint to normal behaviour to allow for unconfirmed exit and normal behaviour on exit
			padTop "1"
			if [ "$username" != "" ]						#If a user is logged in still
				loadBar 0.1 "Goodbye $username; Exiting..."
				#Log footer info
				local endUnix=$(date +%s)					#Get time as unix timestamp
				local totalTime=$(( endUnix-startUnix ))	#Calculate program runtim

				#Time conversion from https://stackoverflow.com/a/40782247
				local hoursRan=$(( totalTime/3600 ))
				local minutesRan=$(( $(( totalTime/60 ))-$(( 60*hoursRan )) ))
				local secondsRan=$(( totalTime%60 ))

				#Make login time notes of the current user before exit
				logoutTime=$(date +%s)
				loggedInDuarion=$(( logoutTime-loginTime ))
				#This makes it easy to do user usage time reporting
				echo "User: $username was forcefully logged out; They were logged in for $loggedInDuarion seconds" >> Uasge.db
			else
				loadBar 0.1 "Goodbye; Exiting..."
			fi

			#Basic log footer
			echo -e "\nRun lasted $hoursRan hours, $minutesRan minutes and $secondsRan seconds" >> Uasge.db
			echo -e "END OF RUN at $(date -Iseconds)\n" >> Uasge.db
			sleep 1.5
			clear
			exit
		elif [ "$leave" = "N" ] || [ "$leave" = "n" ]; then
			clear
			padTop "1"
			centerText "Shortly resuming program from prior prompt..." "R"
			echo -e "Exit cancelled, program resuming\n" >> Uasge.db			#Note that the exit was cancelled
			trap "confirmQuit" INT
			sleep 2
			return		#Attempt to go back to where exit was requested
		else
			centerText "Please enter Y/N to continue..." "R"
		fi
	done
}

#Override SIGINT to do our bidding; https://stackoverflow.com/a/14702379
trap "confirmQuit" INT

#Will echo for now rather than export to file

#Called with Type, Optionally colour
barDraw(){
	barCounter=1
	termWidth=$(stty size | cut -d " " -f 2)		#gives two space seperated numbers, height and width
	if [ $# -eq 2 ]; then
		colour=$2
	else
		colour=$default
	fi

	printf "$colour"	#Set colour for this bar instance
	termWidth=$(( termWidth-1))
	if [ "$1" = "T" ]; then							#Top bar (angled down corners)
		printf "/"
		while [ $barCounter -lt $termWidth ]; do
			printf "%0.s-"							#Printf doesn't add a newline by default, so is ideal for this, could have used echo -n instead
			barCounter=$(( barCounter+1 ))
		done
		printf "\\"
	elif [ "$1" = "B" ]; then						#Bottom bar (angled up corners)
		printf "\\"
		while [ $barCounter -lt $termWidth ]; do
			printf "%0.s-"
			barCounter=$(( barCounter+1 ))
		done
		printf "/"
	elif [ "$1" = "J" ]; then						#Middle bar (flat edges)
		printf "|"
		while [ $barCounter -lt $termWidth ]; do
			printf "%0.s-"
			barCounter=$(( barCounter+1 ))
		done
		printf "|"
	elif [ "$1" = "S" ]; then						#Just a line the widdth of the terminal
		while [ $barCounter -le $((termWidth+1)) ]; do
			printf "%0.s-"
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
	printf "$colour"					#Set colour for this instance
	if [ "$2" = "M" ]; then				#Menu centering adds a pipe on the left and right edges to match with the bars in the above function
		printf "|"; printf "%*s" "$(( padding-1 ))"; printf "$textColour""$text""$colour"; printf "%*s" "$(( padding-1 ))"; printf "|"
		echo -e "\033[0m"				#Reset to term default colour
	elif [ "$2" = "R" ]; then			#Regular centering doesn't add the pipes on the edges
		printf "%*s" $padding; printf "$text"; printf "%*s" $padding;
		echo -e "\033[0m"				#Reset to term default colour
	elif [ "$2" = "Q" ]; then			#Query centering is the same as regular, but allows for the predicted input length to be entered so that is centered
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
	#You'll see a lot of $(stty size) in this program
	termHeight=$(stty size | cut -d " " -f 1)
	if [ "$1" = "Menu" ]; then				#If it's menu centering for the main menu we know the sizes already
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
		while [ "$padCount" -le "$padding" ]; do	#Echo new lines until we are at the desired height
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

#Called with a pause value and the text to show
loadBar(){
	local count=1
	termWidth=$(stty size | cut -d " " -f 2)
	barScaler=$(( $(( termWidth-20 )) ))	#Leave some whitespace on the sides
	while [ "$count" -le 20 ]; do
		local refresh="$(( count%2 ))"
		if [ "$refresh" -eq 0 ]; then		#Don't refresh every cycle
			clear
			local bar=$(printf "$purple"; echo -n "<"; printf "%*s" $(( $(( barScaler/25 ))*count )) | tr " " "-"; echo ">")	#Heres the load bar for this run
			local barLen=$(( $(( $(( barScaler/25 ))*count ))+2 ))		#Embedding $(()) in more $(()) feels wrong, but it seems to work
			local leftGap=$(( $(( termWidth-barLen ))/2 ))
			local passedTextSize=${#2}									#Find how long the passed string is
			local textSize=$(( passedTextSize+4 ))						#Add four to the string length for the space 00%
			padTop "3"													#Bar has three lines
			printf "%*s" $leftGap; printf "$bar"; echo ""				#Draw bar on top
			#Manually centering text so I didn't need to rework the centering function yet again...
			printf "$green"; printf "%*s" $(( $(( termWidth-textSize ))/2 )); echo "$2 $(( count*5 ))%"
			printf "%*s" $leftGap; printf "$bar"; echo ""				#Draw bar on bottom
		fi
		count=$(( count+1 ))
		sleep $1
	done
	clear
	padTop "1"
	centerText "Loading Complete!" "R" "$default"
	sleep 0.8
	clear
	return 0
}

#Called with nothing
drawMainMenu(){
	padTop "Menu"
	barDraw "T" "$cyan"
	#I should probably have changed the menu header text to something like "Welcome $username", but this has been there since hour 1 of work, so I'ma leave it out of respect for it
	centerText "Hewwo!" "M" "$cyan" "$default"
	barDraw "J" "$cyan"
	centerText "" "M" "$cyan"
	centerText "1)     Login      " "M" "$cyan" "$default"
	centerText "2) Regen Sim Data " "M" "$cyan" "$default"
	centerText "3)    FIFO Sim    " "M" "$cyan" "$default"
	centerText "4)    LIFO Sim    " "M" "$cyan" "$default"
	centerText "5)   Pass Change  " "M" "$cyan" "$default"
	if [ "$username" = "admin" ]; then		#Only show admin options if logged in as admin
		centerText "" "M" "$cyan"
		barDraw "J" "$cyan"
		centerText "" "M" "$cyan"
		centerText "6)   Admin    " "M" "$cyan" "$default"
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

	if [ "$#" -ne "2" ]; then			#Only called with a second arg if comming from account creation
		#Clear simdata file
		rm "simdata_$username.job"
		touch "simdata_$username.job"
		genFor="$username"
	else
		genFor="$2"
	fi

	while [ "$byteNo" -lt "$count" ]; do
		#Generate the byte
		byte=$(head /dev/urandom | od -An -N1 -d)	#https://linuxsimply.com/bash-scripting-tutorial/operator/arithmetic-operators/random-number/
		byte=$(( byte % 100 ))						#% 100 was decent advise from a friend for how to constrain the output of od

		#0 pad on left if only one digit, then add a B at the start
		if [ "${#byte}" -eq 1 ]; then
			cleanedByte="B0$byte"
		elif [ "${#byte}" -eq 2 ]; then
			cleanedByte="B$byte"
		fi

		if [ "$byteNo" -eq "0" ]; then
			loadBar "0.1" "Generating..."
		fi
		#Check if byte is already written
		if [ "$(grep -c $cleanedByte simdata_$genFor.job)" -ne 0 ]; then
			#This text isn't needed, but I think it's cool to see when it had to regen a byte
			centerText "Byte collision, regenning byte $(( byteNo+1 ))" "R" "$yellow"	#Needs +1 as byteNo is still on prior byte as this collided
		elif [ "$byteNo" -eq "$(( count-1 )) " ]; then
			byteNo=$(( byteNo+1 ))		#Increment by 1 as no collision
			echo -n "$cleanedByte" >> "simdata_$genFor.job"		#Don't add a comma for the last value
		else
			byteNo=$(( byteNo+1 ))		#Increment by 1 as no collision
			echo -n "$cleanedByte," >> "simdata_$genFor.job"
		fi
	done
	centerText "Regeneration complete, please press enter to continue" "Q" "0"; read -r		#Allow user to read any text, then move on when prompted
	return 0
}

#Menu options
loginHandler(){
	if [ "$username" != "" ]; then		#Allow the user the option of logging out instead of needing to restart program
		padTop 1
		centerText "You are already logged in, logout? Y/N: " "Q" "1"; read -r logout
		if [ "$logout" = "Y" ] || [ "$logout" = "y" ]; then
			logoutTime=$(date +%s)		#Get the unix timestamp
			loggedInDuarion=$(( logoutTime-loginTime ))	#Calculate login duration and log it
			echo "User: $username logged out; They were logged in for $loggedInDuarion seconds" >> Uasge.db
			unset username				#Clear the username variable, thought I had issues with username="" here, so switched to unset to be safe
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
			tempUsername=$(echo "$tempUsername" | tr '[:upper:]' '[:lower:]')			#Menu options and logins are case insensitive, so make lower case
			if [ "$tempUsername" = "bye" ]; then	#Check for exit intent
				confirmQuit "LOGIN"
			elif [ "$tempUsername" = "back" ] || [ "$tempUsername" = "exit" ]; then		#Check if they tried to leave login system and allow it
				return 2
			fi
			centerText "Enter password: " "R"; read -r -s password
			password=$(echo "$password" | tr '[:upper:]' '[:lower:]')
			if [ "$password" = "bye" ]; then
				confirmQuit "LOGIN"
			elif [ "$tempUsername" = "back" ] || [ "$tempUsername" = "exit" ]; then
				return 2
			fi

			echo -e "\n"; centerText "So you wish to attempt to login as: $tempUsername? Y/N: " "Q" "1"; read -r loginConfirm
			loginConfirm=$(echo "$loginConfirm" | tr '[:upper:]' '[:lower:]')
			if [ "$loginConfirm" = "" ] || [ "${#tempUsername}" -eq 0 ]; then
				echo "No input supplied, returning to menu"
				return 0
			fi
			if [ "$loginConfirm" = "y" ]; then		#If they are happy with their entries
				if [ "$(cat ./UPP.db | grep -i "$tempUsername" | cut -d"," -f2 | tr -d '\t')" = "$tempUsername" ]; then			#Check for username match
					if [ $(cat ./UPP.db | grep -i "$tempUsername" | cut -d"," -f5 | tr -d '\t') = "ACTIVE" ]; then				#Check if account is active
						if [ "$(cat ./UPP.db | grep -i "$tempUsername" | cut -d"," -f3 | tr -d '\t')" = "$password" ]; then		#Check for pasword match
							username="$tempUsername"							#Set the username to the temp username
							centerText "Welcome $username" "R"					#Show login confirm message
							echo "User logged in as $username" >> Uasge.db		#Log that they logged in
							loginTime=$(date +%s)								#Take note of login time for login duration logging on logout
							tempUsername=""										#Clear temp username
							password=""											#Clear temp password

							#Ask about regenning sim data
							clear
							padTop 3
							centerText "Do you wish to regen your simdata? Y/N: " "Q" "1"; read -r regenQueue
							if [ "$regenQueue" = "Y" ] || [ "$regenQueue" = "y" ]; then
								#Brief asked for 10 bytes, but I wanted to allow a choice of size, so it asks and defaults to 10 if no or non numeric input
								centerText "How many bytes do you want to generate? (Default 10): " "Q" "2"; read -r queueSize
								if [ "$queueSize" = "" ] || [[ "$queueSize" =~ [^0-9] ]]; then
									queueSize=10
								fi
								genQueue "$queueSize"		#Generate the simdata file; No args because it is for this user
							else
								centerText "Skipping simdata regen..." "R"
							fi

							return 0			#Exit back to menu on successful login
						else
							clear; padTop "1"; centerText "Incorrect password, try again" "R" "$red"	#Don't return so they can retry
						fi
					else
						clear; padTop "1"; centerText "Account is marked is inactive, please contact the administrator" "R" "$red"
						return 1		#Return as account is inactive
					fi
				else
					centerText "Username not found, try again";
				fi
			elif [ "$loginConfirm" = "n" ]; then
				centerText "Please re-enter username and password when prompted" "R"
			elif [ "$loginConfirm" = "bye" ]; then			#Check for exit intent
				confirmQuit "LOGIN"
				elif [ "$loginConfirm" = " back" ] || [ "$loginConfirm" = " exit" ]; then	#See if user wishes to return to menu
				break;
			else
				centerText "Unknown option, please try again"
			fi
			sleep 5			#Pause for 5 seconds to allow user to read error message
			clear
		done
	fi
}
callFIFO(){
	if [ "$username" = "" ]; then		#Don't allow non logged in users to run a sim
		echo "Please login before trying to run a simulation"
		return 1
	fi
	echo "User: $username ran the FIFO sim" >> Uasge.db
	. ./HelperScripts/FIFO-Sim.sh		#Source the FIFO-Sim file for functions
}
callLIFO(){
	if [ "$username" = "" ]; then		#Don't allow non logged in users to run a sim
		echo "Please login before trying to run a simulation"
		return 1
	fi
	echo "User: $username ran the LIFO sim" >> Uasge.db
	. ./HelperScripts/LIFO-Sim.sh		#Source the LIFO-Sim file for functions
}
passChangeHandler(){
	padTop "3"; centerText "Password change" "R" "$green"

	centerText "Please enter the username you wish to change the password for: " "Q" "5"; read -r tempUsername
	tempUsername=$(echo "$tempUsername" | tr '[:upper:]' '[:lower:]')			#Convert username given to lower case
	if [ "$tempUsername" = "bye" ]; then										#Check for exit intent
		confirmQuit "PASS-CHANGE"
	elif [ "$tempUsername" = "back" ] || [ "$tempUsername" = "exit" ]; then		#Leave the program if user has changed mind
		return 2
	fi

	centerText "Please enter the pin for user $tempUsername: " "Q" "3"; read -r -s checkPin
	checkPin=$(echo "$checkPin" | tr '[:upper:]' '[:lower:]')
	if [ "$checkPin" = "bye" ]; then											#Check for exit intent
		confirmQuit "PASS-CHANGE"
	elif [ "$tempUsername" = "back" ] || [ "$tempUsername" = "exit" ]; then		#Leave the program if user has changed mind
		return 2
	fi

	#Check entered info
	if [ "$(cat ./UPP.db | grep -i "$tempUsername" | cut -d"," -f2 | tr -d '\t')" = "$tempUsername" ]; then			#If entered username exists
		if [ $(cat ./UPP.db | grep -i "$tempUsername" | cut -d"," -f5 | tr -d '\t') = "ACTIVE" ]; then				#If account is active
			if [ "$checkPin" != "$(cat ./UPP.db | grep -i "$tempUsername" | cut -d"," -f4 | tr -d '\t')" ]; then	#If given pin does not match stored pin
				centerText "Pin does not match records, please try again" "R" "$red"								#Error and return to menu
				sleep 2
				clear
				return 1
			fi
		else
			centerText "User is marked as inactive, please contact the administrator" "R" "$purple"		#Say account inactive. Eventually this may allow a pass change and reactivate the account
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
	newPassword=$(echo "$newPassword" | tr '[:upper:]' '[:lower:]')					#Convert to lower
	if [ "$newPassword" = "bye" ]; then												#Check for exit intent
		confirmQuit "PASS-CHANGE"
	elif [ "$newPassword" = "back" ] || [ "$newPassword" = "exit" ]; then			#Leave function if wanted
		return 2
	fi
	centerText "Please confirm the new password: " "Q" "1"; read -rs confirmPassword
	confirmPassword=$(echo "$confirmPassword" | tr '[:upper:]' '[:lower:]')
	if [ "$confirmPassword" = "bye" ]; then											#Check for exit intent
		confirmQuit "PASS-CHANGE"
	elif [ "$confirmPassword" = "back" ] || [ "confirmPassword" = "exit" ]; then	#Leave function if wanted
		return 2
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
		local accountStatus=$(cat ./UPP.db | grep "$tempUsername" | cut -d"," -f5 | tr -d '\t')

		local targetID=$(cat ./UPP.db | grep "$tempUsername" | cut -d"," -f1 | tr -d '\t')		#Get the user ID from the database
		local targetLine=$(( targetID+2 ))														#Add two to the ID as line 1 is header, line 2 is admin
		local oldLine=$(cat ./UPP.db | grep "$tempUsername")									#Get the line matching the username

		#Manually build the line as I cannot find an easy way to substitute one var for another without sed
		local newLine="$targetID,\t$tempUsername,\t$confirmPassword,\t$checkPin,\t$accountStatus"

		local linesBefore=$(( targetLine-1 ))													#Get number of lines before the line to rewrite
		local linesAfter=$(( $(wc -l UPP.db | cut -d" " -f1)-$targetLine ))						#Get number of lines after the line to rewrite

		mv UPP.db UPP.db.bak										#Copy database to a temp file
		echo "$(head -n $linesBefore UPP.db.bak)" > UPP.db			#Write all lines before line to rewrite into a new database
		echo -e "$newLine" >> UPP.db								#Echo the changed line into the database
		echo "$(tail -n $linesAfter UPP.db.bak)" >> UPP.db			#Write all lines after the line to rewrite into the database
		rm UPP.db.bak												#Remove the backup of the database from before the changes

		echo -e "\n"; centerText "Password changed successfully" "R" "$green"
		echo "Password was successfully changed for User: $tempUsername" >> Uasge.db

		centerText "Returning to menu in two seconds"
		sleep 2
		return 0
	else
		centerText "Passwords did not match; Please try again" "R" "$red"
		sleep 2
		clear
		return 1
	fi
}
adminStuffs(){
	if [ "$username" != "admin" ]; then									#Silently reject nonAdmin accounts
		return 1
	fi
	while true; do
		#Draw admin menu
		padTop "13"
		barDraw "T" "$green"
		centerText "Administrative Options" "M" "$green" "$cyan"
		barDraw "J" "$green"
		centerText "" "M" "$green"
		centerText "1)   Create an Account  " "M" "$green" "$cyan"
		centerText "2)   Delete an Account  " "M" "$green" "$cyan"
		centerText "3)    Sim Statistics    " "M" "$green" "$cyan"
		centerText "4)   Account Rankings   " "M" "$green" "$cyan"
		centerText "" "M" "$green" "$cyan"
		barDraw "J" "$green"
		centerText "Back" "M" "$green" "$red"
		barDraw "B" "$green"

		echo -e "\n"; centerText "Enter an option: " "Q" "1"; read -r adminChoice		#Prompt for option
		adminChoice=$(echo "$adminChoice" | tr '[:upper:]' '[:lower:]')					#Convert to lower case
		. ./HelperScripts/AdminStuffs.sh												#Source the Admin file for functions

		#Check input
		if [ "$adminChoice" = "1" ] || [ "$adminChoice" = "create" ]; then
			makeAccount
		elif [ "$adminChoice" = "2" ] || [ "$adminChoice" = "delete" ]; then
			deleteAccount
		elif [ "$adminChoice" = "3" ] || [ "$adminChoice" = "stats" ]; then
			simStats
		elif [ "$adminChoice" = "4" ] || [ "$adminChoice" = "rankings" ]; then
			accountRankings
		#elif [ "$adminChoice" = "3" ] || [ "$adminChoice" = "Change Pin" ]; then
		#	echo "This will allow for a PIN change"
		elif [ "$adminChoice" = "back" ]; then
			echo "Returning to main menu"
			clear
			return 0
		elif [ "$adminChoice" = "bye" ]; then
			confirmQuit "ADMIN-MENU"
		else
			echo "Please enter a valid option from the above menu"
			sleep 2
		fi
		clear
	done
}

#Start Program
clear

#Logfile header, Middle printf bit from: https://stackoverflow.com/a/5349796
printf "|" >> Uasge.db; printf "%80s" | tr " " "=" >> Uasge.db; printf "|" >> Uasge.db
echo -e "\n\nNEW RUN start for terminal: $(echo $TERM) at time: $(date -Iseconds)\n" >> Uasge.db

loadBar "0.18" "Program loading... Please wait"		#A 0.18 step delay felt about right

#Program loop
while true; do
	drawMainMenu
	echo -e "\n"; centerText "Enter an option: " "Q" "3"; read -r menuChoice
	menuChoice=$(echo "$menuChoice" | tr '[:upper:]' '[:lower:]')	#Change input to lower case
	clear	#Ensure there is no residual after entering an option

	#Write menu entry to log
	if [ "$username" = "" ]; then
		echo "Unknown user entered $menuChoice on the main menu" >> Uasge.db
	else
		echo "User $username entered $menuChoice on the main menu" >> Uasge.db
	fi

	if [ "$menuChoice" = "1" ] || [ "$menuChoice" = "login" ]; then
		loginHandler
	elif [ "$menuChoice" = "2" ] || [ "$menuChoice" = "regen sim data" ]; then
		clear
		padTop 1
		centerText "Enter how many bytes you wish to generate: " "Q" "2"; read -r newSimData
		genQueue "$newSimData"
	elif [ "$menuChoice" = "3" ] || [ "$menuChoice" = "fifo sim" ]; then
		callFIFO
	elif [ "$menuChoice" = "4" ] || [ "$menuChoice" = "lifo Sim" ]; then
		callLIFO
	elif [ "$menuChoice" = "5" ] || [ "$menuChoice" = "pass change" ]; then
		passChangeHandler
	elif [ "$menuChoice" = "6" ] || [ "$menuChoice" = "admin" ]; then
		if [ "$username" = "admin" ]; then
			adminStuffs
		else		#Silently reject and log
			echo "Please enter a valid option from the menu, or enter Bye to exit at any time"
			echo "Unauthorized user attempted to access the admin menu" >> Uasge.db
			sleep 2
		fi
	elif [ "$menuChoice" = "exit" ] || [ "$menuChoice" = "bye" ]; then
		confirmQuit "MENU"
	else
		echo "Please enter a valid option from the menu, or enter Bye to exit at any time"
		sleep 2
	fi
	clear
done
