################################################################
#
# Author: Tahsin Turkoz
# Date: 06.21.2015
# Explanation: Reads Perflogger output from files and sum the 
#              run times for the same sections including requested 
#              tag. 
# 
# Example Usage
#    sump_perf.sh "/tmp/asda*" secondary
#
#################################################################

if [ "$#" -ne 2 ] 
then 
	echo "illegal number of parameters"
	echo "Usage: $0 filename distinctive_expression"
	exit
fi

ls -1 $1|while read fname
do
	echo -n "$(basename $fname): "
	grep -A1 $2 $fname|grep "run time"|cut -d' ' -f3|tr -d 'ms'|awk '{ sum+=$1} END {print sum,"ms"}'
done
