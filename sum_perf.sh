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

if [ "$#" -le 2 ] 
then 
	echo "illegal number of parameters"
	echo "Usage: $0 distinctive_expression filename(s)"
	exit
fi

ls -1 ${@:2}|while read fname
do
	echo -n "$(basename $fname): "
	grep -A1 $1 $fname|grep "run time"|cut -d' ' -f3|tr -d 'ms'|awk '{ sum+=$1} END {print sum,"ms"}'
done
