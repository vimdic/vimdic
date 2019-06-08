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
SEARCH_URL="http://small.dic.daum.net/search.do?q="
EX_URL="https://small.dic.daum.net/word/view.do?wordid="

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

	# Get word id
	WORD_ID=$(wget -q -O - "$SEARCH_URL$TARGET" |\
		grep "tit_cleansch" |\
		# striping unnecessary tags
		sed -e 's/<strong class="tit_cleansch @//g' |\
		sed -e 's/\">//g' |\
		# remove white space from beginning
		sed -e 's/^\s*\s//g')

	# Get meaning
	printf "\n[ $CLR_YELL$TARGET$CLR_ORIG ]\n\n**** 주요뜻 ****\n"
	wget -q -O - "$SEARCH_URL$TARGET" |\
		# Trimming the useful section
		sed -n -e "/영어사전/,/tit_word/p" |\

		# Trimming line which including below parameter
		# txt_searchword : searched word
		# word id : all of meaning
		# </ul> : replace to newline
		grep "txt_searchword\|word id\|<\/ul>" | sed -e 's/\t//g' |\

		# Wraping with [] to the word in the (> ~ <) from the text including "link_txt"
		sed -e 's/"txt_searchword"[^>]*>/>[ /g' |\
		sed -e 's/<\/a>/ ]<\/a>/g' |\

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
		wget -q -O - "$EX_URL$WORD_ID" |\
			grep "<daum:word" | sed -e 's/\t//g' |\
			sed -e 's/^[^>]*</</g' |\
			sed -e 's/<[^>]*>//g' |\
			sed -e "s/$TARGET/$CLR_YELL$TARGET$CLR_ORIG/"
			more
	fi


fi
