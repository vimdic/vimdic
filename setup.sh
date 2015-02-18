#!/bin/bash

SET_DIR=/usr/local/bin
IS_LOCALE_SET=$(locale -a | grep -c ko_KR.utf8)
IS_CLIPBOARD_SET=$(vim --version | grep -c [+]clipboard)
VD=vimdic.sh

chmod 775 $VD
if [ "$1" == "-rm" ]; then
	sudo rm $SET_DIR/$VD
else
	if [ -f $SET_DIR/$VD ]; then
		echo "Vimdic already set"
	else
		echo "Setting vimdic.."

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

		if [ $IS_CLIPBOARD_SET == 0 ]; then
			echo "Starting clipboard setting"
			sudo apt-get install vim-gnome
			if [ $IS_CLIPBOARD_SET == 0]; then
				echo "Fail to setup vim clipboard"
			else
				echo "Success to setup vim clipboard"
			fi
		else
			echo "Already set vim clipboard"
		fi

		sudo cp $VD $SET_DIR
		echo "nmap tt :!vimdic.sh<Space><cword><CR>">> ~/.vimrc
		echo "xmap tt \"+y<ESC>:!vimdic.sh<Space><C-R><C-O>\"<CR>">> ~/.vimrc
		source ~/.bashrc
	fi
fi
