#!/bin/sh
if [ $USER = "root" ] ; then
	black="\033[0;30m"
	orange="\033[0;33m"
	blue="\033[0;34m"
	nc="\033[0m"

	echo ""
	echo " "${black}"MMMMMMMMMMMMMMMMMM"${orange}"III"${black}"MMMMMMMMMMMMMMMMMMM"${nc}
	echo " "${black}"MMMMMMMMMMMMMMMMMM"${orange}"III"${black}"MMMMMMMMMMMMMMMMMMM"${nc}
	echo " "${black}"MMMMMM"${orange}"??"${black}"MMMMMMMMMM"${orange}"III"${black}"MMMMMMMMMM"${orange}"??"${black}"MMMMMMM"${nc}
	echo " "${black}"MMMMMM"${orange}"IIII"${black}"MMMMMMMM"${orange}"O?Z"${black}"MMMMMMMM"${orange}"IIII"${black}"MMMMMMM"${nc}
	echo " "${black}"MMMMMMMM"${orange}"IIII"${black}"MMMMMMMMMMMMMMM"${orange}"IIII"${black}"MMMMMMMMM"${nc}
	echo " "${black}"MMMMMMMMMM"${orange}"II"${black}"MMMMMM"${orange}"7II"${black}"MMMMMM"${orange}"I?"${black}"MMMMMMMMMMM"${nc}
	echo " "${black}"MMMMMMMMMMMMMMM"${orange}"IIIIIIIIID"${black}"MMMMMMMMMMMMMMM"${nc}
	echo " "${black}"MMMMMMMMMMMMM"${orange}"?IIIIIIIIIII?"${black}"MMMMMMMMMMMMMM"${nc}
	echo " "${black}"MMMMMMMMMMMM"${orange}"IIIIII"${black}"MMM"${orange}"?IIII?"${black}"MMMMMMMMMMMMM"${nc}
	echo " "${black}"MO"${orange}"IIIIIII"${black}"MMM"${orange}"IIIID"${black}"MMMMM"${orange}"D?III"${black}"MMM"${orange}"?IIIIII"${black}"MMM"${nc}
	echo " "${black}"MMM"${orange}"IIIII"${black}"MMMM"${orange}"IIII"${black}"MMMMMMM"${orange}"IIII8"${black}"MMM"${orange}"IIIII"${black}"MMMM"${nc}
	echo " "${black}"MMMMMMMMMMMM"${orange}"III?"${black}"MMMMMMM"${orange}"?III8"${black}"MMMMMMMMMMMM"${nc}
	echo " "${black}"MMMMMMMM"${blue}"O8888888888888888888888"${black}"MMMMMMMMM"${nc}
	# echo " "${black}"MMMMMMMM"${blue}"88888888888888888888888"${black}"MMMMMMMMM"${nc}
	echo " "${black}"MMMMMMMM"${blue}"88888888888888888888888"${black}"MMMMMMMMM"${nc}
	echo " "${black}"MMMMMMMM"${blue}"88888888888888888888888"${black}"MMMMMMMMM"${nc}
	echo " "${black}"MMMMMMMM"${blue}"888888888"${black}"DMMMN"${blue}"888888888"${black}"MMMMMMMMM"${nc}
	echo " "${black}"MMMMMMMM"${blue}"8888888888"${black}"MMM"${blue}"O888888888"${black}"MMMMMMMMM"${nc}
	echo " "${black}"MMMMMMMM"${blue}"88888888888"${black}"M"${blue}"88888888888"${black}"MMMMMMMMM"${nc}
	echo " "${black}"MMMMMMMM"${blue}"88888888888"${black}"M"${blue}"88888888888"${black}"MMMMMMMMM"${nc}
	echo " "${black}"MMMMMMMM"${blue}"88888888888888888888888"${black}"MMMMMMMMM"${nc}
	# echo " "${black}"MMMMMMMM"${blue}"88888888888888888888888"${black}"MMMMMMMMM"${nc}
	echo " "${black}"MMMMMMMM"${blue}"8888888888888888888888O"${black}"MMMMMMMMM"${nc}
	echo " "${black}"MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"${nc}
	echo " "${black}"MM"${nc}"Let's Encrypt Updater by Punk__Rock"${black}"MMM"${nc}
	echo ""
	echo ""

	cd /opt/

	if ping -c 2 google.com >> /dev/null 2>&1; then
		echo " Downloading..."

		apt-get install -y git-core > /dev/null

		if [ -d "certbot/" ]; then
			action="updated"
			
			rm -rf certbot/
			
			git clone https://github.com/certbot/certbot --quiet
		else
			action="installed"
			
			git clone https://github.com/certbot/certbot --quiet
		fi

		echo ""
		echo " Let's Encrypt was "$action" to the latest version !"
		echo " Path : /opt/certbot/"
		echo ""
	else
		echo ""
		echo " You are not connected to internet please check your connection !"
		echo ""
	fi
else
	echo "You are not root :("
	echo ""
fi
