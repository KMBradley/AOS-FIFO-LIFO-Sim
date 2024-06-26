#!/usr/bin/env sh

#echo "Admin Addon File sourced!"

makeAccount(){
	clear
	padTop "18"																						#Pad screen assuming 8 lines of text
	centerText "Account Creation" "R"																#Show mode to admin
	echo ""
	centerText "Usernames and passwords are 5 alphanumeric chars long, pins are 3 numeric chars long" "R" "$red"		#Reminder for username, password and pin formatting

	#Username creation and availability check
	echo -e "\n"; centerText "Enter username: " "Q" "5"; read -r tempUsername
	if [ "$tempUsername" = "bye" ]; then
		confirmQuit "ACCOUNT-MAKE"
	elif [ "${#tempUsername}" -lt 5 ]; then													#Check if username less than 5 chars
		centerText "Username is too short, please try again" "R" "$red"
		return 1
	elif [ "${#tempUsername}" -gt 5 ]; then													#Check if username more than 5 chars
		centerText "Username is too long, please try again" "R" "$red"
		return 1
	elif [ "$(cat ./UPP.db | grep -ci "$tempUsername")" -ne 0 ]; then						#Check if username is in use (Active or Disabled)
		centerText "Username is already in use, please try another username" "R" "$red"
		return 1
	elif [[ "$1" =~ [^0-9a-zA-Z] ]]; then													#Test for non alphanumerics
		centerText "Username contains non-alphanumeric characters, please try another username" "R" "$red"
		return 1
	#Password creation and validation
	else
		centerText "Username is available" "R" "$green"
		echo -e "\n"; centerText "Enter desired password: " "Q" "1"; read -r -s tempPassword; echo ""
		centerText "Re-enter desired password: " "Q" "1"; read -r -s confirmPassword
		if [ "$tempPassword" != "$confirmPassword" ]; then									#Check if passwords match
			centerText "Passwords do not match, please try again" "R" "$red"
			return 1
		elif [ "${#tempPassword}" -lt 5 ]; then												#Check if password less than 5 chars
			centerText "Password is too short, please try again" "R" "$red"
			return 1
		elif [ "${#tempPassword}" -gt 5 ]; then												#Check if password more than 5 chars
			centerText "Password is too long, please try again" "R" "$red"
			return 1
		elif [[ "$1" =~ [^0-9a-zA-Z] ]]; then
			centerText "Password contains non-alphanumeric characters, please try another username" "R" "$red"		#I hate that specials aren't allowed here by the brief, but eh
			return 1

		#Pin creation and validation
		else
			echo ""; centerText "Password confirmed" "R" "$green"
			echo -e "\n"; centerText "Enter desired pin: " "Q" "1"; read -r -s tempPin; echo ""
			centerText "Confirm pin: " "Q" "1"; read -r -s confirmPin
			echo ""
			if [ "$tempPin" != "$confirmPin" ]; then												#Check if pins match
				centerText "Pins do not match, please try again" "R" "$red"
				return 1
			elif [ "${#tempPin}" -lt 3 ]; then														#Check if pin less than 3 chars
				centerText "Pin is too short, please try again" "R" "$red"
				return 1
			elif [ "${#tempPin}" -gt 3 ]; then														#Check if pin more than 3 chars
				centerText "Pin is too long, please try again" "R" "$red"
				return 1
			elif [[ "$1" =~ [^0-9] ]]; then
				centerText "Pin contains non numerics, please try again" "R" "$red"
				return 1

			#Save account info
			else
				echo ""; centerText "Pins matched, writing information to database" "R" "$green"
				local lowerUN=$(echo "$tempUsername" | tr '[:upper:]' '[:lower:]')		#Change both to lower
				local lowerPW=$(echo "$tempPassword" | tr '[:upper:]' '[:lower:]')
				local currentMaxID=$(tail -n 1 ./UPP.db | cut -d"," -f1)				#Find current max user ID
				local thisID=$(( currentMaxID+1 ))										#Add one for this user ID
				local toWrite="$thisID,\t$lowerUN,\t$lowerPW,\t$tempPin,\tACTIVE"		#Format info to match file (comma tab seperated)
				echo -e $toWrite >> ./UPP.db											#Write info to file

				touch ./simdata_$lowerUN.job											#Make the simdata file
				genQueue "10" "$lowerUN"													#Pass username to make it for
				return 0
			fi
		fi
	fi
}

#This will deactivate the account, not delete it. Makes log checking easier and UIDs always one larger than the last
deleteAccount(){
	clear
	padTop "5"
	centerText "Account deletion: Procede with caution" "R" "$red"

	#Figure out if a username, ID number or random garbage was entered
	echo -e "\n"; centerText "Enter username or user ID: " "Q" "4"; read -r usedIdentifier
	if [ "$usedIdentifier" = "Bye" ]; then
		confirmQuit "ACCOUNT-DEL"
	elif [ "${#usedIdentifier}" -eq 5 ]; then
		delType="UN"
	elif [[ "$usedIdentifier" =~ [^0-9] ]]; then
		centerText "This is not a valid username or pin, please try again" "R" "$red"
		return 2
	elif [ "${#usedIdentifier}" -le 4 ]; then
		delType="ID"
	else			#Advancement get! \nHow did we even get here?
		centerText "I don't know how we got here; Input didn't fall into selection criteria" "R" "$purple"
		return 1
	fi

	#Find who the ID belongs to
	if [ "$delType" = "ID" ]; then
		if [ "$(cat ./UPP.db | cut -d',' -f1 | tr -d '\t' | grep -c "$usedIdentifier")" -eq 0 ]; then
			centerText "ID number $usedIdentifier does not exist; Please check input and retry" "R"; sleep 2
			return 1
		else
			delUsername=$(cat ./UPP.db | head -n$(( usedIdentifier+2 )) | tail -n1 | cut -d',' -f2 | tr -d '\t')
			echo -e "\n"; centerText "So you wish to delete user $delUsername? Y/N: " "Q" "1"; read -r confirmDelByID
			if [ "$confirmDelByID" = "N" ]; then
				centerText "Aborting..." "R"
				return 1
			fi
		fi

	#Check the usernanme actually exists
	elif [ "$delType" = "UN" ]; then
		if [ "$(cat ./UPP.db | grep -c "$usedIdentifier")" -eq 0 ]; then
			centerText "Username $usedIdentifier does not exist; Please check input and retry" "R"
			return 1
		else
			delUsername=$(cat ./UPP.db | grep "$usedIdentifier" | cut -d"," -f2 | tr -d '\t')	#Not needed, but maybe helps sanitise
			echo -e "\n"; centerText "So you wish to delete user $delUsername? Y/N: " "Q" "1"; read -r confirmDelByUN
			if [ "$confirmDelByUN" = "N" ]; then
				centerText "Aborting..." "R"
				return 1
			fi
		fi
	fi

	#Pin confirm
	echo -e "\n"; centerText "Enter pin for user $delUsername?: " "Q" "3"; read -r -s pinCheck; echo -e "\n"
	#Above ending echo is there because this didn't add a new line at the end like all prior invocations
	if [ ${#pinCheck} -ne 3 ]; then
		centerText "This is not a valid pin" "R" "$red"
		return 1
	elif [ "$(cat ./UPP.db | grep "$delUsername" | cut -d',' -f4 | tr -d '\t')" -eq "$pinCheck" ]; then
		centerText "Pin confirmed" "R" "$green"; sleep 2
	else
		centerText "Incorrect pin entered; Please check input and try again" "R"
		return 1
	fi

	#Final check and mark as inactive
	clear
	padTop 4
	centerText "Continuing will mark $delUsername as inactive, this cannot be reverted for now." "R" "$red"
	centerText "Continue? Y/N: " "Q" "1"; read -r confirmDelete

	if [ "$confirmDelete" = "N" ] || [ "$confirmDelete" = "n" ]; then
		centerText "Aborting..." "R"
		return 1
	elif [ "$confirmDelete" = "Y" ] || [ "$confirmDelete" = "y" ]; then

		#This block is an abomination, and I may as well be Doc Frankenstein for having made it
		#But; "IT'S ALIVE!!"
		targetID=$(cat ./UPP.db | grep "$delUsername" | cut -d"," -f1 | tr -d '\t')	#Get the ID of the user
		targetLine=$(( targetID+2 ))			#Add two so ID is now line number (line 1 is header, line 2 is admin[id 0])
		oldLine=$(cat ./UPP.db | grep "$delUsername")
		newLine="${oldLine//ACTIVE/INACTIVE}"	#Bashism to change active to inactive, works on tinycore sh too!

		linesBefore=$(( targetLine-1 ))
		linesAfter=$(( $(wc -l UPP.db | cut -d" " -f1)-targetLine ))

		#Option 7 from https://www.baeldung.com/linux/insert-line-specific-line-number it is jank, but it works; Thus is it jank?
		mv UPP.db UPP.db.bak									#Create backup of UPP.db to pull old info from
		echo "$(head -n $linesBefore UPP.db.bak)" > UPP.db		#Copy all lines before the user to modify
		echo "$newLine" >> UPP.db								#Write modified user info
		echo "$(tail -n $linesAfter UPP.db.bak)" >> UPP.db		#Copy all lines after the user to modify
		rm UPP.db.bak

		clear; padTop "1"; centerText "User $delUsername successfully marked as inactive" "R" "$red"
		sleep 2
		return 0
	fi
}

#Same menu is used for per user and global, so it was brought here
simStatsModeMenu(){
	clear
	#Show the submenu
	padTop "13"
	barDraw "T" "$green"
	centerText " Simulation Statistics" "M" "$green" "$cyan"
	barDraw "J" "$green"
	centerText "" "M" "$green"
	centerText "1)   FIFO   " "M" "$green" "$cyan"
	centerText "2)   LIFO   " "M" "$green" "$cyan"
	centerText "3)  Overall " "M" "$green" "$cyan"
	centerText "" "M" "$green" "$cyan"
	barDraw "J" "$green"
	centerText "Back" "M" "$green" "$red"
	barDraw "B" "$green"
}

#Sim popularity contests
simStats(){
	while true; do
		clear
		#Show a menu
		padTop "12"
		barDraw "T" "$green"
		centerText " Simulation Statistics" "M" "$green" "$cyan"
		barDraw "J" "$green"
		centerText "" "M" "$green"
		centerText "1)  Per User  " "M" "$green" "$cyan"
		centerText "2)   Global   " "M" "$green" "$cyan"
		centerText "" "M" "$green" "$cyan"
		barDraw "J" "$green"
		centerText "Back" "M" "$green" "$red"
		barDraw "B" "$green"

		echo -e "\n"; centerText "Enter choice: " "Q" "4"; read -r statsChoice
		statsChoice=$(echo "$statsChoice" | tr '[:upper:]' '[:lower:]')

		if [ "$statsChoice" = "bye" ]; then
			confirmQuit "STATS-MENU"
		elif [ "$statsChoice" = "back" ]; then
			break
		elif [ "$statsChoice" -eq "1" ] || [ "$statsChoice" = "user" ]; then
			simStatsModeMenu
			echo -e "\n"; centerText "Enter choice: " "Q" "4"; read -r statsMode
			statsMode=$(echo "$statsMode" | tr '[:upper:]' '[:lower:]')
			centerText "Enter the username to get statistics for: " "Q" "5"; read -r findUser
			findUser=$(echo "$findUser" | tr '[:upper:]' '[:lower:]')

			#Get run counts for the chosen user
			#Search for the username supplied, then search for how many instances of each sim type were found
			local usageFIFO=$(cat "./Uasge.db" | grep -i "$findUser" | grep -c "FIFO")
			local usageLIFO=$(cat "./Uasge.db" | grep -i "$findUser" | grep -c "LIFO")
			local usageTotal=$(( usageFIFO+usageLIFO ))

			#Show based on selection
			if [ "$statsMode" -eq "1" ] || [ "$statsMode" = "fifo" ]; then		#Show only FIFO
				clear
				padTop 4
				centerText "FIFO Stats for user: $findUser" "R"
				centerText "FIFO sims were ran $usageFIFO times" "R"
			elif [ "$statsMode" -eq "2" ] || [ "$statsMode" = "lifo" ]; then	#Show only LIFO
				clear
				padTop 4
				centerText "LIFO Stats for user: $findUser" "R"
				centerText "LIFO sims were ran $usageLIFO times" "R"
			elif [ "$statsMode" -eq "3" ] || [ "$statsMode" = "overall" ]; then	#Show both, and a total
				clear
				padTop 7
				centerText "Total stats for user: $findUser" "R"
				centerText "FIFO sims were ran $usageFIFO times" "R"
				centerText "LIFO sims were ran $usageLIFO times" "R"
				echo -e "\n"; centerText "Overall, $findUser has run $usageTotal sims!" "R"
			elif [ "$statsMode" = "back" ]; then
				break;
			elif [ "$statsMode" = "bye" ]; then
				confirmQuit "STATS-MENU"
			else
				clear; padTop "1"
				centerText "Invalid option, please try again" "R"
			fi
		elif [ "$statsChoice" -eq "2" ] || [ "$statsChoice" = "global" ]; then
			simStatsModeMenu
			echo -e "\n"; centerText "Enter choice: " "Q" "4"; read -r statsMode
			statsMode=$(echo "$statsMode" | tr '[:upper:]' '[:lower:]')

			#Get global run count, search for all instances of FIFO and LIFO as there is nothing that logs those words other than the sims
			local usageFIFO=$(cat "./Uasge.db" | grep -c "FIFO")
			local usageLIFO=$(cat "./Uasge.db" | grep -c "LIFO")
			usageTotal=$(( usageFIFO+usageLIFO ))

			if [ "$statsMode" -eq "1" ] || [ "$statsMode" = "fifo" ]; then		#Show only FIFO
				clear
				padTop 4
				centerText "Global FIFO runs" "R"
				centerText "$usageFIFO FIFO sims were ran" "R"
			elif [ "$statsMode" -eq "2" ] || [ "$statsMode" = "lifo" ]; then	#Show only LIFO
				clear
				padTop 4
				centerText "Global LIFO runs" "R"
				centerText "$usageLIFO LIFO sims were ran" "R"
			elif [ "$statsMode" -eq "3" ] || [ "$statsMode" = "overall" ]; then	#Show both and a running total
				clear
				padTop 7
				centerText "Total global statistics" "R"
				centerText "$usageFIFO FIFO sims have been run" "R"
				centerText "$usageLIFO LIFO sims have been run" "R"
				echo -e "\n"; centerText "Overall, this program has ran $usageTotal simulations!" "R"
			elif [ "$statsMode" = "back" ]; then
				break;
			elif [ "$statsMode" = "bye" ]; then
				confirmQuit "STATS-MENU"
			else
				clear; padTop "1"
				centerText "Invalid option, please try again" "R"
			fi
		else
			clear; padTop "1"
			centerText "Invalid option, please try again"
		fi
		echo -e "\n"; centerText "Press enter to continue..." "R"; read -r
	done
}

#Called with username
getLoginTime(){
	local loginTime

	#https://stackoverflow.com/a/16318005
	while read -r hit; do
		#https://stackoverflow.com/a/52947167
		thisLoginTime=$(echo "$hit" | grep -i $1 | cut -d";" -f2 | grep -o -E '[0-9]+')
		#I had a bug with the above line when a username had numbers in it, caused havoc for a good 30 mins
		#Cause was that the line returned by the first grep not being sanitised, so was including the numbers from the username
		#Fixed with a cut
		loginTime=$(( loginTime+thisLoginTime ))
	done < <(cat Uasge.db | grep -i "logged in for")
	echo $loginTime
}

#Be able to show logon time per user, and rank every user registered
accountRankings(){
	while true; do
		clear
		#Show a menu
		padTop "12"
		barDraw "T" "$green"
		centerText "User Rankings" "M" "$green" "$cyan"
		barDraw "J" "$green"
		centerText "" "M" "$green"
		centerText "1) User usage time  " "M" "$green" "$cyan"
		centerText "2)  User rankings   " "M" "$green" "$cyan"
		centerText "" "M" "$green" "$cyan"
		barDraw "J" "$green"
		centerText "Back" "M" "$green" "$red"
		barDraw "B" "$green"

		echo -e "\n"; centerText "Enter an option: " "Q" "2"; read -r rankingType
		rankingType=$(echo "$rankingType" | tr '[:upper:]' '[:lower:]')		#Convert to lower case

		if [ "$rankingType" = "bye" ]; then
			confirmQuit "RANKINGS"
		elif [ "$rankingType" = "back" ] || [ "$rankingType" = "exit" ]; then
			return 2
		elif [ "$rankingType" -eq "1" ]; then
			clear
			padTop 6
			centerText "Which user do you wish to find the total time of: " "Q" "5"; read -r rankUser
			rankUser=$(echo "$rankUser" | tr '[:upper:]' '[:lower:]')

			usersTime=$(getLoginTime "$rankUser")							#Source for this is in confirmQuit
			local hoursIn=$(( usersTime/3600 ))								#Divide by 60*60
			local minutesIn=$(( $(( usersTime/60 ))-$(( 60*hoursIn )) ))	#Divide by 60 and subtract the hour count in minutes
			local secondsIn=$(( usersTime%60 ))								#Get seconds by dividing by 60 and getting the remainder

			echo ""; centerText "$rankUser has been logged in for a cumulative total of:" "R" "$purple"
			centerText "$hoursIn hours, $minutesIn minutes and $secondsIn seconds" "R" "$cyan"

			echo ""; centerText "Press enter to continue" "Q" "0"; read -r
		elif [ "$rankingType" -eq "2" ]; then
			count=1
			while [ "$count" -lt $(wc -l UPP.db | cut -d' ' -f1 ) ]; do		#Find number of lines in database
				count=$(( count+1 ))	#Starting count should be 2, as line 1 is header

				currentLine=$(head -n "$count" UPP.db | tail -n1)		#Get current line by getting the first x lines, then only the last
				local username=$(echo "$currentLine" | cut -d',' -f2 | tr -d '\t')
				if [ "${#username}" -eq 5 ]; then						#If the username is under 5 chars (junk essentially)
					local loggedInCount=$(cat Uasge.db | grep -ic $username)
					echo "$loggedInCount:$username" >> tmp.txt			#Output to a temp file
				fi
			done
			sort -rn tmp.txt -o tmpSort.txt			#Sort the output file

			clear
			totalRankings=$(wc -l tmpSort.txt | cut -d" " -f1)
			if [ "$totalRankings" -lt 5 ]; then				#If there's less than 5 registered accounts
				padTop $(( totalRankings+8 ))
				local count=0

				#High scores style menu
				barDraw "T" "$green"
				centerText " User Login Rankings" "M" "$green" "$cyan"
				barDraw "J" "$green"
				centerText "" "M" "$green"
				while [ $count -lt "$totalRankings" ]; do
					count=$(( count+1 ))
					local info=$(head -n $count tmpSort.txt | tail -n1 )									#Get the next highest line
					local stats="$(echo $info | cut -d":" -f2): $(echo $info | cut -d":" -f1) times"	#Format as username: login count
					local lenCheck=${#stats}															#0 pad if needed
					if [ $(( lenCheck%2 )) -ne 0 ]; then
						stats=" $stats"
					fi
					centerText "$stats" "M" "$green" "$cyan"
				done
				centerText "" "M" "$green"
				barDraw "B" "$green"
			else
				padTop "13"
				local count=0
				barDraw "T" "$green"
				centerText " User Login Rankings" "M" "$green" "$cyan"
				barDraw "J" "$green"
				centerText "" "M" "$green"
				while [ $count -lt 5 ]; do
					count=$(( count+1 ))
					local info=$(head -n $count tmpSort.txt | tail -n1 )
					local stats="$(echo $info | cut -d":" -f2): $(echo $info | cut -d":" -f1) times"
					local lenCheck=${#stats}															#0 pad if needed
					if [ $(( lenCheck%2 )) -ne 0 ]; then
						stats=" $stats"
					fi
					centerText "$stats" "M" "$green" "$cyan"
				done
				centerText "" "M" "$green"
				barDraw "B" "$green"
			fi
			rm tmp.txt tmpSort.txt			#Remove the temp ranking files

			echo -e "\n"; centerText "Press enter to exit" "R"; read -r
		else
			echo -e "\n"; centerText "Invalid option; please try again" "R" "$red"
			sleep 2
		fi
	done
}
