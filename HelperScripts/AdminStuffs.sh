#!/usr/bin/env sh

echo "Admin Addon File sourced!"

makeAccount(){
	clear
	padTop "8"																											#Pad screen assuming 8 lines of text
	centerText "Account Creation" "R"																					#Show mode to admin
	echo ""
	centerText "Usernames and passwords are 5 alphanumeric chars long, pins are 3 numeric chars long" "R" "$red"		#Reminder for username, password and pin formatting

	#Username creation and availability check
	echo -ne "\nEnter username: "; read -r tempUsername
	if [ "${#tempUsername}" -lt 5 ]; then																				#Check if username less than 5 chars
		echo "Username is too short, please try again"
		return 1
	elif [ "${#tempUsername}" -gt 5 ]; then																				#Check if username more than 5 chars
		echo "Username is too long, please try again"
		return 1
	elif [ "$(cat ./UPP.db | grep -c "$tempUsername")" -ne 0 ]; then													#Check if username is in use (Active or Disabled)
		echo "Username is already in use, please try another username"

	#Password creation and validation
	else
		echo "Username is available"
		echo -ne "\nEnter desired password: "; read -r -s tempPassword
		echo -ne "\nRe-enter desired password: "; read -r -s confirmPassword
		echo ""
		if [ "$tempPassword" != "$confirmPassword" ]; then																#Check if passwords match
			echo "Passwords do not match, please try again"
			return 1
		elif [ "${#tempPassword}" -lt 5 ]; then																			#Check if password less than 5 chars
			echo "Password is too short, please try again"
			return 1
		elif [ "${#tempPassword}" -gt 5 ]; then																			#Check if password more than 5 chars
			echo "Password is too long, please try again"
			return 1

		#Pin creation and validation
		else
			echo "Password confirmed"
			echo -ne "\nEnter desired pin "; read -r -s tempPin
			echo -ne "\nConfirm pin "; read -r -s confirmPin
			echo ""
			if [ "$tempPin" != "$confirmPin" ]; then																	#Check if pins match
				echo "Pins do not match, please try again"
				return 1
			elif [ "${#tempPin}" -lt 3 ]; then																			#Check if pin less than 3 chars
				echo "Pin is too short, please try again"
				return 1
			elif [ "${#tempPin}" -gt 3 ]; then																			#Check if pin more than 3 chars
				echo "Pin is too long, please try again"
				return 1

			#Save account info
			else
				echo "Pins matched, writing information to database"
				currentMaxID=$(tail -n 1 ./UPP.db | cut -d"," -f1)														#Find current max user ID
				thisID=$(( currentMaxID+1 ))																			#Add one for this user ID
				toWrite="$thisID,\t$tempUsername,\t$tempPassword,\t$tempPin,\tACTIVE"									#Format info to match file (comma tab seperated)
				echo -e $toWrite >> ./UPP.db																			#Write info to file
			fi
		fi
	fi
}

#This will deactivate the account, not delete it. Makes log checking easier and UIDs always one larger than the last
deleteAccount(){
	echo "AA"																											#TEMP	TEMP	TEMP
}
