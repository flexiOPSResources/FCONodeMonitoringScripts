#!/bin/bash -X

#Location for files to be created. This example explores the use of two clusters with one management coming
NODEIPS=$( node-tool -l -v | grep 'Node IP' | awk '{print $3}')
#Replace ip with required IP address

NODEIPSC2=$( sshe 11.222.33.44 node-tool -l -v | grep 'Node IP' | awk '{print $3}')

NODEDIR="/opt/extility/skyline/war/nodeid/"

DATE=$(date "+%Y-%m-%dT%H:%M:%S")

echo "" > $NODEDIR/Cluster1.csv
echo "" > $NODEDIR/Cluster1tmp.csv
sed -i -e '1iID,IP\' $NODEDIR/Cluster1tmp.csv
echo "" > $NODEDIR/Cluster2.csv
echo "" > $NODEDIR/Cluster2tmp.csv
sed -i -e '1iID,IP\' $NODEDIR/Cluster2tmp.csv

for i in $NODEIPS

	do 
		touch $NODEDIR/Cluster1.csv

		NODEID=$(node-tool -v -v $i | grep 'Node ID:'|tail -n 1 | awk '{print $3}')
		
		echo $NODEID,$i >> $NODEDIR/Cluster1tmp.csv 
	

	done


for n in $NODEIPSC2

        do 	
                touch $NODEDIR/Cluster2.csv

                NODEID2=$(sshe 11.222.33.44 node-tool -v -v $n | grep 'Node ID:' | tail -n 1  | awk '{print $3}')
                
                echo $NODEID2,$n >>  $NODEDIR/Cluster2tmp.csv | sed '/^$/d'

        done


cat $NODEDIR/Cluster1tmp.csv | sed '/^\s*$/d' > $NODEDIR/Cluster1.csv
cat $NODEDIR/Cluster2tmp.csv  | sed '/^\s*$/d' > $NODEDIR/Cluster2.csv
rm -f $NODEDIR/Cluster1tmp.csv
rm -f $NODEDIR/Cluster2tmp.csv

