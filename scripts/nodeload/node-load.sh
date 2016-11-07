#!/bin/bash

NODEIPS=$( node-tool -l -v | grep 'Node IP' | awk '{print $3}')

NODEDIR="/opt/extility/skyline/war/nodeload/"

for i in $NODEIPS

	do 
		touch $NODEDIR$i.csv
		if  ! grep -q 'NODEIP,LOAD' $NODEDIR$i.csv ; then

			sed -i -e '1iNODEIP,LOAD\' $NODEDIR$i.csv;
		fi
	done
./node-load.pl -l -v
