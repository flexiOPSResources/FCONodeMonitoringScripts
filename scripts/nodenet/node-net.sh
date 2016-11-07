#!/bin/bash

NODEIPS=$( node-tool -l -v | grep 'Node IP' | awk '{print $3}')
NODEIPSC2=$( sshe 10.0.0.1 node-tool -l -v | grep 'Node IP' | awk '{print $3}')

NODEDIR="/opt/extility/skyline/war/nodenet/"
NODEDIRC2="/opt/extility/skyline/war/nodenet/"

DATE=$(date "+%Y-%m-%dT%H:%M:%S")

for i in $NODEIPS

	do 
		touch $NODEDIR$i.csv
		if  ! grep -q 'DATE,rxbyt/s,txbyt/s' $NODEDIR$i.csv ; then

			sed -i -e '1iDATE,rxbyt/s,txbyt/s\' $NODEDIR$i.csv;
		fi

		NODENET=$(sshe $i  sar -n DEV  1 5 | grep eth1 | tail -n 1|awk '{print $5"," $6}')
		
		echo $DATE,$NODENET >> $NODEDIR$i.csv

	done


for n in $NODEIPSC2

        do 
                touch $NODEDIRC2$n.csv
                if  ! grep -q 'DATE,rxbyt/s,txbyt/s' $NODEDIRC2$n.csv ; then

                        sed -i -e '1iDATE,rxbyt/s,txbyt/s\' $NODEDIRC2$n.csv;
                fi

                NODENETC2=$(sshe 10.0.0.1 sshe $n  sar -n DEV  1 5 | grep eth1 | tail -n 1|awk '{print $5"," $6}')
                
                echo $DATE,$NODENETC2 >> $NODEDIRC2$n.csv

        done

