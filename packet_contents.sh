################################################################
#
# Author: Tahsin Turkoz
# Date: 07.07.2015
# Explanation: Get the list of files required by the minimized  
#              JS File
#
#################################################################

usage() {
	echo
	echo "Usage:  $0 [JSFile(s)|Directory]"
	echo 
	exit
}

if [ $# -lt 1 ]
then
	usage
else
	for name in ${@:1}
	do
		if [ ! -f "$name" -a ! -d "$name" ]
		then
			echo "$name is not a valid file or directory."
			echo
			exit
		fi
	done
	for filename in $(ls -1 ${@:1})
	do	
		echo
		echo $filename
		echo "--------------------------------"
		cat $filename|tr ',;}' '\n'| grep '^define("'|sed 's/define(//g'|tr -d '"'|sed '$ d' 
	done
fi	

