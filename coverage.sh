################################################################
#
# Author: Tahsin Turkoz
# Date: 06.22.2015
# Explanation: Adds coverage.logCallee() function call at the  
#              begining of each function in given file 
#
#################################################################

if [ $# -lt 2 -o ! -f "$2" ]
then
	echo "Usage: $0 -(a|r) JSFile(s)"
	echo "       $0 -l JSFile [coverage_result.csv]"
	echo
	exit
fi


if [ "$1" = "-r" ]
then
	ls -1 ${@:2}|while read fname
	do
		if [ -f "$fname" ]
		then
			sed -i '/coverage.logCallee/d' $fname
			echo "$fname cleared"
		fi
	done
elif [ "$1" = "-a" ]
then
	ls -1 ${@:2}|while read fname 
	do
		if [ -f "$fname" ]
		then	
			first_time="1"
			omit_next_bracket="0"
			temFile=/tmp/tempFile
			> $temFile

			# If EOL is not entered to the lase line
			while IFS= read -r line || [ -n "$line" ]
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
					if [ "$first_time" -eq 1 ]
					then
						echo
						echo $fname
						echo ---------------------------------------------
						first_time="0"
					fi
					
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
			done < $fname

			mv $fname ${fname}.bak
			cat $temFile > $fname
		fi
	done			
elif [ "$1" = "-l" ]
then
	if [ -n "$3" -a -f "$3" ]
	then
		sed 's/^\s*//' $2| grep -nE "((:|=)|^)\s*function.*\(.*\)" |sed 's/{.*$//' > /tmp/function_list
		jsname="$(echo "$(cd "$(dirname "$2")"; pwd)/$(basename "$2")"|sed 's-/var/www/asda2/wwwroot/assets/theme_default-/theme-')"
		while read LineNum
		do
			#echo $LineNum
			sed -i "/^${LineNum}:/d" /tmp/function_list
		done <<< "$(grep "^\"$jsname" "$3"|cut -d'"' -f6|grep -v "Line")"
		
		echo "Not covered functions in $2"
		echo "------------------------------------------------"
		
		cat /tmp/function_list|more
	else
		sed 's/^\s*//' $2| grep -nE "((:|=)|^)\s*function.*\(.*\)" |sed 's/{.*$//'
	fi
fi
