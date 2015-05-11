#!/bin/bash

SET_DIR=/usr/local/bin
IS_LOCALE_SET=$(locale -a | grep -c ko_KR.utf8)
VD=vimdic.sh
DUMP_DIR=~/.dump_vimdic
MAC=Darwin
LINUX=Linux
WHICH_SYSTEM=$(uname -s)

chmod 775 $VD
if [ "$1" == "-rm" ]; then
	if [ -f $SET_DIR/$VD ]; then
		sudo rm $SET_DIR/$VD
		if [[ $WHICH_SYSTEM == $MAC ]]; then
			sed -i '' "/^nmap tt/d" ~/.vimrc
			sed -i '' "/^xmap tt/d" ~/.vimrc
		elif [[ $WHICH_SYSTEM == $LINUX ]]; then
			sed -i "/^nmap tt/d" ~/.vimrc
			sed -i "/^xmap tt/d" ~/.vimrc
		fi
		rm $DUMP_DIR
		echo "Removing vimdic is done.."
	else
		echo "Removing vimdic is already done.."
	fi
else
	if [ -f $SET_DIR/$VD ]; then
		echo "Vimdic already set"
	else
		echo "Setting vimdic.."

		if [[ $WHICH_SYSTEM == $MAC ]]; then
			echo "On the Mac OS X"
			echo "Installing Homebrew which is packages manager for OSX like 'apt-get' for debian linux"
			ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
			echo "Installing GNU utility : gnu-sed"
			brew install gnu-sed --with-default-names
		elif [[ $WHICH_SYSTEM == $LINUX ]]; then

			# Set locale to ko_KR.UTF-8
			if [ $IS_LOCALE_SET == 0 ]; then
				echo "Starting locale setting"
				sudo locale-gen ko_KR.UTF-8
				sudo dpkg-reconfigure locales
				if [ $(locale -a | grep -c ko_KR.utf8) == 0 ]; then
					echo "Fail to setup locale"
				else
					echo "Success to setup locale"
				fi
			else
				echo "Already set locale"
			fi

			echo "Installing w3m to open web page"
			sudo apt-get install w3m
		fi

		echo "cp $VD to $SET_DIR"
		sudo cp $VD $SET_DIR
		echo "Added mapping key 'tt' into ~/.vimrc"
		echo "nmap tt :!vimdic.sh<Space><cword><CR>">> ~/.vimrc
		echo "xmap tt y<ESC>:!vimdic.sh<Space><C-R>\"<CR>">> ~/.vimrc
		source ~/.bashrc
		echo "Vimdic setup is done."
	fi
fi
