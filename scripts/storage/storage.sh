#!/bin/bash -X


STORAGEDIR="/opt/extility/skyline/war/storage/"

DATE=$(date "+%Y-%m-%dT%H:%M:%S")

echo touch $STORAGEDIR/Cluster1.csv
#touch $STORAGEDIRCluster1.csv
#		if  ! grep -q 'DATE,Used Bytes' $STORAGEDIR/Cluster1.csv ; then
#
#			sed -i -e '1iDATE,Used Bytes' $STORAGEDIR/Cluster1.csv;
#		fi
#		
#		STORAGE1=$(ssh -i /etc/extility/sshkeys/id_extility admin@10.158.208.2 /sbin/zfs get -o name,value -Hp used rpool0/sd1 | awk '{print $2}')
#		
#		echo $DATE,$STORAGE1 >> $STORAGEDIR/Cluster1.csv

                if  ! grep -q 'DATE,Used Bytes,Available' $STORAGEDIR/Cluster1.csv ; then

                        sed -i -e '1iDATE,Used Bytes,Available' $STORAGEDIR/Cluster1.csv;
                fi

                STORAGE1KB=$(ceph df -f json-pretty | grep total_used | awk '{print $2}' | sed -e 's/,//g')

                STORAGE1=$(echo $STORAGE1KB*1024 | bc)

		AVAILABLESTORAGE1KB=$(ceph df -f json-pretty | grep total_avail | awk '{print $2}' | sed -e 's/,//g' | sed -e 's/}//g')
		
		AVAILABLESTORAGE1=$(echo $AVAILABLESTORAGE1KB*1024 | bc)
                echo $DATE,$STORAGE1,$AVAILABLESTORAGE1 >> $STORAGEDIR/Cluster1.csv

touch $STORAGEDIR/Cluster2.csv
                if  ! grep -q 'DATE,Used Bytes,Available' $STORAGEDIR/Cluster2.csv ; then

                        sed -i -e '1iDATE,Used Bytes,Available' $STORAGEDIR/Cluster2.csv;
                fi

                STORAGE2KB=$(sshe 10.0.0.1 ceph df -f json-pretty | grep total_used | awk '{print $2}' | sed -e 's/,//g')
		
		STORAGE2=$(echo $STORAGE2KB*1024 | bc)

		AVAILABLESTORAGE2KB=$(sshe 10.0.0.1 ceph df -f json-pretty | grep total_avail | awk '{print $2}' | sed -e 's/,//g' | sed -e 's/}//g')
                
                AVAILABLESTORAGE2=$(echo $AVAILABLESTORAGE2KB*1024 | bc)


                echo $DATE,$STORAGE2,$AVAILABLESTORAGE2 >> $STORAGEDIR/Cluster2.csv


