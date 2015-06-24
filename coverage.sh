################################################################
#
# Author: Tahsin Turkoz
# Date: 06.22.2015
# Explanation: Adds coverage.logCallee() function call at the  
#              begining of each function in given file 
#
#################################################################

if [ $# -ne 2 -o ! -f "$2" ]
then
	echo "Usage: $0 -(a|r) filename"
fi


if [ "$1" = "-r" ]
then
	sed -i '/coverage.logCallee/d' $2
elif [ "$1" = "-a" ]
then
	omit_next_bracket="0"
	temFile=/tmp/tempFile
	> $temFile

	while IFS= read -r line
	do
		#If { was put to previous line
		if [ "$omit_next_bracket" -eq 1 ]
		then
			echo -n "$line"|tr -d "{" >> $temFile
			omit_next_bracket="0"
		else
			echo -n "$line" >> $temFile
		fi
		# function defination lines
		if echo "$line"|grep -qE "((:|=)|^)\s*function.*\(.*\)"
		then
			echo -n "Added coverage after: "
			  
			# { is in the same line and } is not there. 
			# If } there probably empty function do not
			# think about it. Probably empty
			if echo "$line"|grep -q "{"
			then 
				echo >> $temFile
				if echo "$line"|grep -qv "}"
				then
					echo -e ' \tcoverage.logCallee();' >> $temFile
					echo "$line"|xargs|tr -d "{"
				fi
			else
				echo " {" >> $temFile
				echo -e ' \tcoverage.logCallee();' >> $temFile
				echo "$line"|xargs
				omit_next_bracket="1"
			fi
			
		else 
			echo >> $temFile
		fi
	done < $2


	mv $2 ${2}.bak
	cat $temFile > $2
fi