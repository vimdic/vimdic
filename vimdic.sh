#!/bin/bash
# func1 : Printing things from between > with <
# func2 : Trimming line which included parameter

DUMP_DIR=~/.dump_vimdic
HISTORY_DIR=~/.history_vimdic
COLOR_SCH=morning
TARGET=$@
MAC=Darwin
LINUX=Linux
WHICH_SYSTEM=$(uname -s)
CLR_YELL=`echo -e '\033[33m'`
CLR_ORIG=`echo -e '\033[0m'`

if [[ "$1" =~ (http|www)(://|s://)?.+ ]]; then
	if [[ $WHICH_SYSTEM == $LINUX ]]; then
		echo "Open web page with vim. Just using tt."
		w3m -dump -no-cookie "$1" > $DUMP_DIR
		vim -c "colorscheme $COLOR_SCH" $DUMP_DIR
	elif [[ $WHICH_SYSTEM == $MAC ]]; then
		echo "Does not yet support feature of opening webpage"
	fi
else
	export LANG=ko_KR.UTF-8
	clear
	# Search history
	echo $TARGET >> $HISTORY_DIR
	# Meaning
	printf "\n[ $CLR_YELL$TARGET$CLR_ORIG ]\n\n**** 주요뜻 ****\n"
	wget -q -O - "http://small.dic.daum.net/search.do?q=$TARGET" |\
		# Trimming the useful section
		sed -n -e "/영어 사전/,/<\/section>/p" |\

		# Trimming line which including below parameter
		# link_txt: 추가의미
		# link_word:동음이의어
		# word id: all of meaning
		# </ul>:replace to newline
		grep "link_txt\|link_word\|word id\|<\/ul>\|동음이의어<\/strong>\|result_fst" | sed -e 's/\t//g' |\

		# Wraping with [] to the word in the (> ~ <) from the text including "link_txt"
		sed -e 's/"link_txt"[^>]*>/"link_txt">[ /g' |\
		sed -e 's/"link_word"[^>]*>/"link_word">[ /g' |\
		sed -e 's/<\/a>/ ]<\/a>/g' |\

		# Things has to replace
		# 1. Adding space for fix problems from gap at the end of rounding number
		sed -e 's/<\/span><daum:word/ <\/span><daum:word/g' |\
		# 2. 동음이의어
		sed -e 's/동음이의어/**** 동음이의어 ****/g' |\
		# 3. 추가 의미
		sed -e 's/result_fst/>**** 추가 의미 ****</g' |\

		# Removing text inside of between '<' and '>'
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
			sed -e "s/$TARGET/$CLR_YELL$TARGET$CLR_ORIG/"
			more
	fi


fi
