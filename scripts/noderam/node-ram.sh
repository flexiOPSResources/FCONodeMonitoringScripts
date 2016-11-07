#!/bin/bash

NODEIPS=$( node-tool -l -v | grep 'Node IP' | awk '{print $3}')
NODEIPSC2=$( sshe 10.0.0.1 node-tool -l -v | grep 'Node IP' | awk '{print $3}')

NODEDIR="/opt/extility/skyline/war/noderam/"
NODEDIRC2="/opt/extility/skyline/war/noderam/"

DATE=$(date "+%Y-%m-%dT%H:%M:%S")

for i in $NODEIPS

	do 
		touch $NODEDIR$i.csv
		if  ! grep -q 'DATE,RAM,TotalRAM' $NODEDIR$i.csv ; then

			sed -i -e '1iDATE,RAM,TotalRAM\' $NODEDIR$i.csv;
		fi

		NODERAM=$(node-tool -v -v $i | grep 'Free RAM' | awk '{print $3}')
		NODEBASERAM=$(node-tool -v -v $i | grep 'Base RAM' | awk '{print $3}')
		
		echo $DATE,$NODERAM,$NODEBASERAM >> $NODEDIR$i.csv

	done


for n in $NODEIPSC2

        do 
                touch $NODEDIRC2$n.csv
                if  ! grep -q 'DATE,RAM,TotalRAM' $NODEDIRC2$n.csv ; then

                        sed -i -e '1iDATE,RAM,TotalRAM\' $NODEDIRC2$n.csv;
                fi

                NODERAMC2=$(sshe 10.0.0.1 node-tool -v -v $n | grep 'Free RAM' | awk '{print $3}')
		NODEBASERAMC2=$(sshe 10.0.0.1 node-tool -v -v $n | grep 'Base RAM' | awk '{print $3}')
                
                echo $DATE,$NODERAMC2,$NODEBASERAMC2 >> $NODEDIRC2$n.csv

        done

