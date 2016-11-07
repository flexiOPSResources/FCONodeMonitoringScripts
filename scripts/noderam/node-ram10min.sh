#!/bin/bash

NODEIPS=$( node-tool -l -v | grep 'Node IP' | awk '{print $3}')
NODEIPSC2=$( sshe 10.0.0.1 node-tool -l -v | grep 'Node IP' | awk '{print $3}')

NODEDIR="/opt/extility/skyline/war/noderam10/"
NODEDIRC2="/opt/extility/skyline/war/noderam10/"

DATE=$(date "+%Y-%m-%dT%H:%M:%S")


cluster1 ()

	{

                NODERAM=$(node-tool -v -v $i | grep 'Free RAM' | awk '{print $3}')
		NODEBASERAM=$(node-tool -v -v $i | grep 'Base RAM' | awk '{print $3}')

                echo $DATE,$NODERAM,$NODEBASERAM >> $NODEDIR$i.csv
	}

cluster2 ()

	{

                NODERAMC2=$(sshe 10.0.0.1 node-tool -v -v $n | grep 'Free RAM' | awk '{print $3}')
		NODEBASERAMC2=$(sshe 10.0.0.1 node-tool -v -v $n | grep 'Base RAM' | awk '{print $3}')

                echo $DATE,$NODERAMC2,$NODEBASERAMC2 >> $NODEDIRC2$n.csv

	}






for i in $NODEIPS

	do 
                if [[ $( grep $(date -d"10 minutes ago" +%H:%M) $NODEDIR$i.csv ) ]] ; then
                        rm -f $NODEDIR$i.csv
			touch $NODEDIR$i.csv
			echo "DATE,RAM,TotalRAM" > $NODEDIR$i.csv
                        cluster1
                else
                        cluster1
                fi 

	done


for n in $NODEIPSC2

        do 
		if [[ $( grep $(date -d"10 minutes ago" +%H:%M) $NODEDIRC2$n.csv ) ]] ; then
			rm -f $NODEDIRC2$n.csv
			touch $NODEDIRC2$n.csv
			echo "DATE,RAM,TotalRAM" > $NODEDIRC2$n.csv
			cluster2
		else
			cluster2
		fi
        done

