################################################################
#
# Author: Tahsin Turkoz
# Date: 06.05.2014
# Explanation: Get updated files from working directory to 
#              git local repository and then pushes the changes 
#              to remote git server
#
#################################################################

working_dir=/var/www/asda2
git_repo=/var/www/github/asda
branch=master

cd $git_repo
git checkout $branch >/dev/null 2>&1

git log -1 --format="%at"|xargs -I{} date -d @{} +%Y%m%d%H%M.%S|xargs -I{} touch -t {} /tmp/time_check
cd $working_dir
search="`find . -newer /tmp/time_check -type f -print`"

if [ -z "$search" ]
then
	echo "Nothing to do. Git is up to date." 
else
	toBeModified=""
	toBeAdded=""
	while read filename
	do
		if [ ! -f $git_repo/$filename ] 
		then
			echo
			echo "$filename (To be added to repository)"
			toBeAdded="${toBeAdded}"$'\n'"${filename}"
			toBeModified="${toBeModified}"$'\n'"${filename}"
		elif ! diff -b -I '\s*perfLogger.*' $filename $git_repo/$filename >/dev/null 2>&1
		then	
			echo
			echo $filename
			echo "------------------------------------------------------"
			diff -b $filename $git_repo/$filename
			toBeModified="${toBeModified}"$'\n'"${filename}"
		fi
	done <<< "$search"
	if [ -n "$toBeModified" ]
	then
		echo
		echo -n "Above files are changed. Ready to go (Y/N): "
		read reply
		if [ "$reply" != "Y" -a "$reply" != "y" ]
		then
			echo "Exiting"
		else
			echo "Continuing"
			echo "$toBeModified"|while read filename
			do
				if [ -n "$filename" ]
				then
					cp $filename $git_repo/$filename
					sed -i '/perfLogger/d' $git_repo/$filename
					echo "$filename has copied"
				fi
			done 
			cd $git_repo
			if [ -n "$toBeAdded" ]
			then
				git add -A
			fi
			if [ -n "$1" ]
			then
				git commit -a -m "$1"
			else
				git commit -a
			fi
			git push
		fi
	else
		echo "Nothing to do. Git is up to date."
	fi
fi
echo

rm /tmp/time_check
