#!/bin/bash 

NODEIPS=$(sshe 11.222.33.44 node-tool -l -v | grep 'Node IP' | awk '{print $3}')

NODEDIR="/opt/extility/skyline/war/nodeload/"

for i in $NODEIPS

	do 
		touch $NODEDIR$i.csv
		if  ! grep -q 'NODEIP,LOAD' $NODEDIR$i.csv ; then

			sed -i -e '1iNODEIP,LOAD\' $NODEDIR$i.csv;
		fi
		
		NODELOAD=$(sshe 11.222.33.44 /root/scripts/nodeload/node-load.pl -v $i)
		ISOTIME=$(date "+%Y-%m-%dT%H:%M:%S") 
		echo $i,$NODELOAD,$ISOTIME >> $NODEDIR$i.csv
	done
