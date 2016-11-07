#!/bin/sh
#Location for files to be created. This example explores the use of two clusters with one management coming
 #directly from the location the script is running and the second where Node tool needs to be ran on a different machine
while true; 
do 
#Replace ip with required IP address

NODEIPS=$( node-tool -l -v | grep 'Node IP' | awk '{print $3}')
NODEIPS2=$(sshe 11.222.33.44 node-tool -l -v | grep 'Node IP' | awk '{print $3}')

NODEDIR="/opt/extility/skyline/war/nodeload10/"
NODEDIR2="/opt/extility/skyline/war/nodeload10/"


DATE=$(date "+%Y-%m-%dT%H:%M:%S")

cluster1 () 

	{
		NODELOAD1=$(/usr/bin/node-tool -v $i | grep Load | awk '{print $2}')
		NODECORE1=$(/usr/bin/node-tool -v $i | grep 'CPU core'| awk '{print $3}')
		echo $i,$NODELOAD1,$NODECORE1,$DATE >> $NODEDIR$i.csv
	}

cluster2 () 
	
	{
		NODELOAD2=$(sshe 11.222.33.44 /usr/bin/node-tool -v $n | grep Load | awk '{print $2}')
		NODECORE2=$(sshe 11.222.33.44 /usr/bin/node-tool -v $n | grep 'CPU core'| awk '{print $3}')
		echo $n,$NODELOAD2,$NODECORE2,$DATE >> $NODEDIR2$n.csv
	}


for i in $NODEIPS

	do 
                if [ $( grep $(date -d"10 minutes ago" +%H:%M) $NODEDIR$i.csv ) ] ; then
                        rm -f $NODEDIR$i.csv
			touch $NODEDIR$i.csv
			echo "NODEIP,LOAD,CORES,DATE" > $NODEDIR$i.csv
			cluster1                        
                else
                        cluster1
                fi & 

	done

for n in $NODEIPS2

	do 
                if [ $( grep $(date -d"10 minutes ago" +%H:%M) $NODEDIR2$n.csv ) ] ; then
                        rm -f $NODEDIR2$n.csv
			touch $NODEDIR2$n.csv
			echo "NODEIP,LOAD,CORES,DATE" > $NODEDIR2$n.csv
			cluster2
                else
                        cluster2
                fi & 

	done
sleep 30
done
