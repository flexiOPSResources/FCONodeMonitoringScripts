#!/bin/bash 


CLUSTER1=/opt/extility/skyline/war/noderamusage/
CLUSTER2=/opt/extility/skyline/war/noderamusage/


getdatacluster1 ()

        {
                #Get data
		RAM=$(sshe $i /usr/bin/free -b | /bin/grep Mem | /usr/bin/awk -v DATE=$(date '+%Y-%m-%dT%H:%M:%S') '{print DATE","$2","$4","$6","$7}' )
		SWAP=$(sshe $i /usr/bin/free -b | /bin/grep Swap | /usr/bin/awk '{print ","$2}' )
		echo $RAM$SWAP >> $CLUSTER1$i.csv
	
        }



for i in $(node-tool -l -v | grep 'Node IP:' | awk '{print $3}') ;
	do
		if [ $( grep $(date -d"10 minutes ago" +%H:%M) $CLUSTER1$i.csv ) ] ; then
			rm -f $CLUSTER1$i.csv
			touch $CLUSTER1$i.csv
			echo "DATE,SIZE,FREE,BUFFERED,CACHED,SWAPUSED" > $CLUSTER1$i.csv
			getdatacluster1
		else
			getdatacluster1	
		fi

	done

#Cluster 2 usage

getdatacluster2 ()
	{
                #GET data
                sshe 10.157.16.11 "/root/scripts/noderam/getusage-ram.sh $n " >> $CLUSTER2$n.csv ;
	}

for n in $(sshe 10.157.16.11 "node-tool -l -v | grep 'Node IP:' |awk '{print \$3}'") ; 
	do  
		if [[ $( grep $(date -d"10 minutes ago" +%H:%M) $CLUSTER2$n.csv ) ]] ; then
                        rm -f $CLUSTER2$n.csv
	                touch $CLUSTER2$n.csv
        	        echo "DATE,SIZE,FREE,BUFFERED,CACHED,SWAPUSED" > $CLUSTER2$n.csv
                        getdatacluster2
                else
                        getdatacluster2
                fi

	done

