#!/bin/bash

SET_DIR=/usr/local/bin
IS_LOCALE_SET=$(locale -a | grep -c ko_KR.utf8)
IS_CLIPBOARD_SET=$(vim --version | grep -c [+]clipboard)
VD=vimdic.sh
DUMP_DIR=~/.dump_vimdic

chmod 775 $VD
if [ "$1" == "-rm" ]; then
	if [ -f $SET_DIR/$VD ]; then
		sudo rm $SET_DIR/$VD
		sed -i "/nmap tt :!vimdic.sh<Space><cword><CR>/d" ~/.vimrc
		sed -i "/xmap tt \"+y<ESC>:!vimdic.sh<Space><C-R><C-O>/d" ~/.vimrc
		rm DUMP_DIR
		echo "Removing vimdic is done.."
	else
		echo "Removing vimdic is already done.."
	fi
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

		echo "Installing w3m to open web page"
		sudo apt-get install w3m

		echo "cp $VD to $SET_DIR"
		sudo cp $VD $SET_DIR
		echo "Added mapping key 'tt' into ~/.vimrc"
		echo "nmap tt :!vimdic.sh<Space><cword><CR>">> ~/.vimrc
		echo "xmap tt \"+y<ESC>:!vimdic.sh<Space><C-R><C-O>\"<CR>">> ~/.vimrc
		source ~/.bashrc
		echo "Vimdic setup is done."
	fi
fi
