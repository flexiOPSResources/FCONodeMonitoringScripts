#!/bin/bash -X

#Location for files to be created. This example explores the use of two clusters with one management coming
 #directly from the location the script is running and the second where Node tool needs to be ran on a different machine.
CLUSTER1=/opt/extility/skyline/war/nodecpu/
CLUSTER2=/opt/extility/skyline/war/nodecpu/
for i in $(node-tool -l -v | grep 'Node IP:' | awk '{print $3}') ;
	do
		#Create files
		touch $CLUSTER1/$i.csv

		#Set CSV headings
		if  ! grep -q 'DATE,CORE,USAGE,SPEED' $CLUSTER1$i.csv ; then
			sed -i -e '1 i\DATE,CORE,USAGE,SPEED' $CLUSTER1$i.csv ;
		fi

		#Get data
		sshe $i "/usr/bin/mpstat -P ALL | /usr/bin/mpstat -P ALL | /usr/bin/awk -v DATE=$(date '+%Y-%m-%dT%H:%M:%S') -v CPUSPEED=$(sshe $i cat /proc/cpuinfo | grep "MHz" | head -n 1 | awk '{print $4}') 'NR>4 {print DATE\",\"\$2\",\"(100 - \$12)\",\"CPUSPEED}'" >> $CLUSTER1$i.csv

	done

#Cluster 2 usage
#Replace ip with required IP address

for n in $(sshe 11.222.33.44 "node-tool -l -v | grep 'Node IP:' |awk '{print \$3}'") ; 
	do  
                #Create files
                touch $CLUSTER2$n.csv

                #Set CSV headings
                if  ! grep -q 'DATE,CORE,USAGE,SPEED' $CLUSTER2$n.csv ; then
                        sed -i -e '1 i\DATE,CORE,USAGE,SPEED' $CLUSTER2$n.csv ;
                fi

		#GET data
		sshe 11.222.33.44 "/root/scripts/nodecpu/getusage.sh $n " >> $CLUSTER2$n.csv ;
done
