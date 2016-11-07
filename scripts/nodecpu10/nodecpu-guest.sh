#!/bin/bash 

#Location for files to be created. This example explores the use of two clusters with one management coming
 #directly from the location the script is running and the second where Node tool needs to be ran on a different machine.
CLUSTER1=/opt/extility/skyline/war/nodecpuguest/
CLUSTER2=/opt/extility/skyline/war/nodecpuguest/


getdatacluster1 ()

        {
                #Get data
	sshe $i "/usr/bin/mpstat -P ALL | /usr/bin/awk -v DATE=$(date '+%Y-%m-%dT%H:%M:%S') 'NR>4 {print DATE\",\"\$2\",\"\$10}'" >> $CLUSTER1$i.csv
        }



for i in $(node-tool -l -v | grep 'Node IP:' | awk '{print $3}') ;
	do
		if [[ $( grep $(date -d"10 minutes ago" +%H:%M) $CLUSTER1$i.csv ) ]] ; then
			rm -f $CLUSTER1$i.csv
			touch $CLUSTER1$i.csv
			echo "DATE,CORE,USAGE" > $CLUSTER1$i.csv
			getdatacluster1
		else
			getdatacluster1	
		fi

	done

#Cluster 2 usage
#Replace ip with required IP address


getdatacluster2 ()
	{
                #GET data
                sshe 11.222.33.44 "/root/scripts/nodecpu/getusage-guest.sh $n " >> $CLUSTER2$n.csv ;
	}

for n in $(sshe 11.222.33.44 "node-tool -l -v | grep 'Node IP:' |awk '{print \$3}'") ; 
	do  
		if [[ $( grep $(date -d"10 minutes ago" +%H:%M) $CLUSTER2$n.csv ) ]] ; then
                        rm -f $CLUSTER2$n.csv
	                touch $CLUSTER2$n.csv
        	        echo "DATE,CORE,USAGE" > $CLUSTER2$n.csv
                        getdatacluster2
                else
                        getdatacluster2
                fi

	done

