#!/bin/bash -X


STORAGEDIR="/opt/extility/skyline/war/storage10/"

DATE=$(date "+%Y-%m-%dT%H:%M:%S")

storagec1 ()
	{
                STORAGE1KB=$(ceph df -f json-pretty | grep total_used | awk '{print $2}' | sed -e 's/,//g')

                STORAGE1=$(echo $STORAGE1KB*1024 | bc)
		
		AVAILABLESTORAGE1KB=$(ceph df -f json-pretty | grep total_avail | awk '{print $2}' | sed -e 's/,//g' | sed -e 's/}//g')
		
		AVAILABLESTORAGE1=$(echo $AVAILABLESTORAGE1KB*1024 | bc)
	
		PERCENTSTORAGE1=$(echo "scale=2; $STORAGE1KB*100/$AVAILABLESTORAGE1KB" | bc)

                echo $DATE,$STORAGE1,$AVAILABLESTORAGE1,$PERCENTSTORAGE1 >> $STORAGEDIR/Cluster1.csv
	}

storagec2 ()
	{
                STORAGE2KB=$(sshe 10.0.0.1 ceph df -f json-pretty | grep total_used | awk '{print $2}' | sed -e 's/,//g')
		
		STORAGE2=$(echo $STORAGE2KB*1024 | bc)

		AVAILABLESTORAGE2KB=$(sshe 10.0.0.1 ceph df -f json-pretty | grep total_avail | awk '{print $2}' | sed -e 's/,//g' | sed -e 's/}//g')
                
                AVAILABLESTORAGE2=$(echo $AVAILABLESTORAGE2KB*1024 | bc)

		PERCENTSTORAGE2=$(echo "scale=2; $STORAGE2KB*100/$AVAILABLESTORAGE2KB" | bc)

                echo $DATE,$STORAGE2,$AVAILABLESTORAGE2,$PERCENTSTORAGE2 >> $STORAGEDIR/Cluster2.csv


	}


if [[ -n $( grep $(date -d"10 minutes ago" +%H:%M) $STORAGEDIR/Cluster1.csv ) ]] ; then
			rm -f $STORAGEDIR/Cluster1.csv
			touch $STORAGEDIR/Cluster1.csv
			echo "DATE,Used Bytes,Available,UsedPercent" > $STORAGEDIR/Cluster1.csv
			storagec1
		else
			storagec1
		fi


if [[ -n $( grep $(date -d"10 minutes ago" +%H:%M) $STORAGEDIR/Cluster2.csv ) ]] ; then
                        rm -f $STORAGEDIR/Cluster2.csv
                        touch $STORAGEDIR/Cluster2.csv
                        echo "DATE,Used Bytes,Available,UsedPercent" > $STORAGEDIR/Cluster2.csv
                        storagec2
                else
                        storagec2
                fi

