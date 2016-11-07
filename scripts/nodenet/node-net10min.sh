#!/bin/bash

NODEIPS=$( node-tool -l -v | grep 'Node IP' | awk '{print $3}')
NODEIPSC2=$( sshe 10.0.0.1 node-tool -l -v | grep 'Node IP' | awk '{print $3}')

NODEDIR="/opt/extility/skyline/war/nodenet10/"
NODEDIRC2="/opt/extility/skyline/war/nodenet10/"

DATE=$(date "+%Y-%m-%dT%H:%M:%S")

cluster1 ()

	{
			NODENET=$(sshe $i  sar -n DEV  1 5 | grep eth1 | tail -n 1|awk '{print $5"," $6}')
		
			echo $DATE,$NODENET >> $NODEDIR$i.csv
	}

cluster2 ()

	{
	                NODENETC2=$(sshe 10.0.0.1 sshe $n  sar -n DEV  1 5 | grep eth1 | tail -n 1|awk '{print $5"," $6}')
                
        	        echo $DATE,$NODENETC2 >> $NODEDIRC2$n.csv
	}



for i in $NODEIPS
        do        
                if [[ $( grep $(date -d"10 minutes ago" +%H:%M) $NODEDIR$i.csv ) ]] ; then
                        rm -f $NODEDIR$i.csv
			touch $NODEDIR$i.csv
			echo "DATE,rxbyt/s,txbyt/s" > $NODEDIR$i.csv
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
                        echo "DATE,rxbyt/s,txbyt/s" > $NODEDIRC2$n.csv
			cluster2
		else
			cluster2
		fi

	done
