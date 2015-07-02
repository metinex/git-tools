################################################################
#
# Author: Tahsin Turkoz
# Date: 06.22.2015
# Explanation: Adds coverage.logCallee() function call at the  
#              begining of each function in given file 
#
#################################################################

if [ $# -lt 2 ]
then
	echo "Usage: $0 -(a|r) JSFile(s)"
	echo "       $0 -l JSFile [coverage_result]"
	echo "       $0 -c coverage_result1 coverage_result2"
	echo "       $0 -m coverage_results"
	echo 
	echo "Used $0 commands are:"
	echo -e "\t-a\tInjects coverage caller as the first line of the each function in JSFile."
	echo -e "\t-r\tRemoves previously injected coverage callers from JSFile."
	echo -e "\t-l\tList name of functions in JSFile. Lists not covered ones if CSV file is also given."
	echo -e "\t-c\tCompare function calles in two different CSV outputs."
	echo -e "\t-m\tMerge CSV outputs and remove dublicates."
	echo 
	exit
else
	for fname in ${@:2}
	do
		if [ ! -f "$fname" ]
		then
			echo "$fname is not a valid filename."
			echo
			exit
		fi
	done
fi


if [ "$1" = "-r" ]
then
	ls -1 ${@:2}|while read fname
	do
		sed -i '/coverage.logCallee/d' $fname
		echo "$fname cleared"
	done
elif [ "$1" = "-a" ]
then
	ls -1 ${@:2}|while read fname 
	do	
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
			# function definition lines
			# excluding ajax calls
			if echo "$line"|grep -vE "(ajaxSettings.|\s)*(success|error)(\s*)(=|:)(\s*)function"|grep -qE "((:|=)|^)\s*(_.once\()*\s*function.*\(.*\)"
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
	done			
elif [ "$1" = "-l" ]
then
	if [ -n "$3" ]
	then	
		sed 's/^\s*//' $2| grep -nE "(=|^)\s*(_.once\()*\s*function.*\(.*\)|(.*)=(.*).extend(\s*)\(" |sed 's/{.*$//'|grep -vE "(ajaxSettings.|\s)*(success|error)(\s*)(=|:)(\s*)function" > /tmp/function_list
		jsname="$(echo "$(cd "$(dirname "$2")"; pwd)/$(basename "$2")"|sed 's-/var/www/asda2/wwwroot/assets/theme_default-/theme-')"
		
		cp $3 /tmp/tempCoverage.cvs
		parentList=();
		while read LineNum
		do
			#echo $LineNum
			if grep -qE "^${LineNum}:" /tmp/function_list
			then
				sed -i "/^${LineNum}:/d" /tmp/function_list
			# Not found function list. Probably parent can be found for there
			else				 	
				fname=$(grep "^\"${jsname}\"" /tmp/tempCoverage.cvs| grep ";\"$LineNum\"" |cut -d'"' -f4)
				parent=$(echo $fname|sed 's/.[[:alnum:]]*$//')
				if [ "$parent" == "" ]
				then
					echo "Function definition not found for $fname. Line:${LineNum}. Omitting!!!"
				elif ! [[ " ${parentList[@]} " =~ " ${parent} " ]];
				then
					echo
					echo "Function definition not found for $fname"
					echo "Trying parent function: $parent"
					if grep -qE ":$parent\s*=" /tmp/function_list
					then
						echo "OK. No problem. Parent found."
						sed -i "/:$parent\s*=/d" /tmp/function_list
						parentList+=("$parent")
					else
						echo "Parent also not found. Omitting it!!!"
					fi
				fi
			fi
		done <<< "$(grep "^\"${jsname}\"" "$3"|cut -d'"' -f6|grep -v "Line")"
		rm /tmp/tempCoverage.cvs

		# Now recheck remaining functions to eliminiate those which are not in root level
		while read line
		do
			linenum=$(echo "$line"|cut -d: -f1)
			openBracket=$(head -$((linenum-1)) $2|grep -o "{"|wc -l)
			closeBracket=$(head -$((linenum-1)) $2|grep -o "}"|wc -l)
			echo -n $line
			if [ "$openBracket" -gt "$closeBracket" ]
			then
				echo " (Have $((openBracket - closeBracket)) parent(s))";
			else 
				echo " (Root level function)"
			fi
		done < /tmp/function_list > /tmp/function_list2

		echo
		echo "Not covered root level functions in $2"
		echo "-------------------------------------------------------------"		
		if grep -q "(Root level function)"  /tmp/function_list2
		then
			grep "(Root level function)"  /tmp/function_list2|sed "s/(Root level function)//g"
		else
			echo "Not found"
		fi
		
		echo
		echo "Functions which are not root level but are probably worth checking."
		echo "--------------------------------------------------------------------"					
		if grep -qv "(Root level function)"  /tmp/function_list2
		then
			grep -v "(Root level function)"  /tmp/function_list2
		else
			echo "Not found"			
		fi
		echo
		
	else
		sed 's/^\s*//' $2| grep -nE "(=|^)\s*(_.once\()*\s*function.*\(.*\)|(.*)=(.*).extend(\s*)\(" |sed 's/{.*$//'|grep -vE "(ajaxSettings.|\s)*(success|error)(\s*)(=|:)(\s*)function"
	fi
elif [ "$1" = "-c" ]
then
	leftAddition=$(diff <(cut -d';' -f1-3 $2)  <(cut -d';' -f1-3 $3)| grep '<')
	if [ -n "$leftAddition" ]
	then	
		echo
		echo "Functions called only in $2"
		echo "----------------------------------"
		echo "$leftAddition"
	fi
	rightAddition=$(diff <(cut -d';' -f1-3 $2)  <(cut -d';' -f1-3 $3)| grep '>')
	if [ -n "$rightAddition" ]
	then
		echo
		echo "Functions called only in $3"
		echo "----------------------------------"
		echo "$rightAddition"
	fi
	echo
elif [ "$1" = "-m" -a $# -gt 2 ]
then
	cat ${@:2}| cut -d";" -f1-3| sort | uniq
fi
