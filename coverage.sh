################################################################
#
# Author: Tahsin Turkoz
# Date: 06.22.2015
# Explanation: Adds coverage.logCallee() function call at the  
#              begining of each function in given file 
#
#################################################################

usage() {
	echo
	echo "Usage: $0 -(a|r) JSFile(s)"
	echo "       $0 -l JSFile [coverage_result]"
	echo "       $0 -c coverage_result1 coverage_result2"
	echo "       $0 -m coverage_results"
	echo "       $0 -n [JSFile(s)|Directory"
	echo 
	echo "Used $0 commands are:"
	echo -e "\t-a\tInjects coverage caller as the first line of the each function in JSFile."
	echo -e "\t-r\tRemoves previously injected coverage callers from JSFile."
	echo -e "\t-l\tList name of functions in JSFile. Lists not covered ones if CSV file is also given."
	echo -e "\t-c\tCompare function calles in two different CSV outputs."
	echo -e "\t-m\tMerge CSV outputs and remove dublicates."
	echo -e "\t-n\tReinjects coverage caller to list of JSFiles or directory"
	echo 
	exit
}

if [ $# -lt 2 ]
then
	usage
elif [ "$1" == "-n" -a -d "$2" ]
then
	echo
	echo "Directory input for reinjection"
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
		if grep -q "coverage.logCallee" $fname
		then
			echo
			echo "$fname looks to be injected before. You following command to reinjection."
			echo "     $0 -n $fname"
			echo
		else
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
		fi
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
					# Chrome includes extended class in class name. It should be extracted
					if echo "$parent" | grep -q ".extend"
					then
						echo "$fname includes name of the extended class. Try to extract it."
						while ! grep -qE ":$parent\s*=" /tmp/function_list && [ "$parent" != "" ]
						do
							parent=$(echo $parent|sed 's/.[[:alnum:]]*$//')
						done
						if [ "$parent" == "" ]
						then
							echo "Could not find child class in JS file. Omitting it!!!"
						else	
							sed -i "/:$parent\s*=/d" /tmp/function_list
							echo "OK. No problem. Child class found: $parent"
						fi
					else
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
elif [ "$1" = "-c" -a -n "$3" ]
then
	echo
	echo "Functions called only in $3"
	echo "---------------------------------------------------"
	while read line 
	do
		linenum=$(echo "$line"|cut -d';' -f3)
		filename=$(echo "$line"|cut -d';' -f3)
		if ! grep "$filename" $2|grep -q "$linenum"
		then
			echo $line
		fi
	done < $3
	echo
	echo "Functions called only in $2"
	echo "---------------------------------------------------"
	while read line 
	do
		linenum=$(echo "$line"|cut -d';' -f3)
		filename=$(echo "$line"|cut -d';' -f3)
		if ! grep "$filename" $3|grep -q "$linenum"
		then
			echo $line
		fi
	done < $2
	echo
elif [ "$1" = "-m" -a $# -gt 2 ]
then
	cat ${@:2}| cut -d";" -f1-3| sort | uniq
elif [ "$1" = "-n" ]
then
	if [ -d "$2" ]
	then
		grep -Rl coverage $2 > /tmp/file_list
		$0 -r $(cat /tmp/file_list)
		$0 -a $(cat /tmp/file_list)
	else
		$0 -r $2
		$0 -a $2	
	fi
else
	usage
fi
