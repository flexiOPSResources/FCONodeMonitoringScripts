#!/bin/bash 

#Location for files to be created. This example explores the use of two clusters with one management coming
 #directly from the location the script is running and the second where Node tool needs to be ran on a different machine.
CLUSTER1=/opt/extility/skyline/war/nodecpuguest/
CLUSTER1=/opt/extility/skyline/war/nodecpuwio/
CLUSTER2=/opt/extility/skyline/war/nodecpuwio/


getdatacluster1 ()

        {
                #Get data
	sshe $i "/usr/bin/mpstat -P ALL | /usr/bin/mpstat -P ALL | /usr/bin/awk -v DATE=$(date '+%Y-%m-%dT%H:%M:%S') 'NR>4 {print DATE\",\"\$2\",\"\$6}'" >> $CLUSTER1$i.csv
        }



for i in $(node-tool -l -v | grep 'Node IP:' | awk '{print $3}') ;
	do

			getdatacluster1	

	done

#Cluster 2 usage

getdatacluster2 ()
	{
                #GET data
                sshe 11.222.33.44 "/root/scripts/nodecpu/getusage-wio.sh $n " >> $CLUSTER2$n.csv ;
	}

for n in $(sshe 11.222.33.44 "node-tool -l -v | grep 'Node IP:' |awk '{print \$3}'") ; 
	do  

                        getdatacluster2
#                fi

	done

