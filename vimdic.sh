#!/bin/bash

DUMP_DIR=~/.dump_vimdic
HISTORY_DIR=~/.history_vimdic
COLOR_SCH=morning
TARGET=$@

if [ "$1" == "-w" ]; then
	echo "Open web page with vim. Just using tt."
	w3m -dump -no-cookie "$2" > $DUMP_DIR
	vim -c "colorscheme $COLOR_SCH" $DUMP_DIR
else
	export LANG=ko_KR.UTF-8
	clear
	# Search history
	echo $TARGET >> $HISTORY_DIR

	# Meaning
	printf "\n[ $TARGET ]\n\n*** 주요뜻 ***\n"
	wget -q -O - "http://small.dic.daum.net/search.do?q=$TARGET" |\
		sed -n -e "/eng_sch/,/<\/section>/p" |\
		grep "link_txt\|txt_means_KUEK\|trans" | sed -e 's/\t//g' |\
		# Wrap [] to target word from string like
		# "???&q=love" class="link_txt" >love</a>"
		sed -e 's/"link_txt"[^>]*>/"link_txt">[ /g' |\
		sed -e 's/<\/a>/ ]<\/a>/g' |\
		sed -e 's/<[^>]*>//g'

	echo " 		      +-----------------------------------------+"
	echo "		      |	종료	 	: Any Key		|"
	echo "		      |	예문 보기	: Space Bar 또는 Enter	|"
	echo " 		      +-----------------------------------------+"
	read -n1 x

	if [ "$x" ]; then
		echo
	else
		# Example
		printf "\n*** 예문 ***\n"
		wget -q -O - "http://small.dic.daum.net/search.do?q=$TARGET&t=example&dic=eng" |\
			grep "<daum:word" | sed -e 's/\t//g' |\
			sed -e 's/^[^>]*</</g' |\
			sed -e 's/<[^>]*>//g' |\
			more
	fi


fi
