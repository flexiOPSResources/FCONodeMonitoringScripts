#!bin/bash

DATE=$(date "+%Y-%m-%dT%H:%M:%S")

NODEIPS=$( node-tool -l -v | grep 'Node IP' | awk '{print $3}')
NODEIPSC2=$( sshe 10.0.0.1 node-tool -l -v | grep 'Node IP' | awk '{print $3}')

GETCURRENTTXRX='DATE=$(date "+%Y-%m-%dT%H:%M:%S") ; for i in `ls /sys/class/net/ | grep eth1 | grep -v "\."` ; do STATUS=$(cat /sys/class/net/$i/carrier 2> /dev/null) ; if [ -z $STATUS ] ; then STATUS='0' ; else if [ $STATUS == 1 ] ; then KBPS=$(cat /sys/class/net/$i/speed) ; R1=`cat /sys/class/net/$i/statistics/rx_bytes` ; T1=`cat /sys/class/net/$i/statistics/tx_bytes` ; sleep 1 ; R2=`cat /sys/class/net/$i/statistics/rx_bytes` ; T2=`cat /sys/class/net/$i/statistics/tx_bytes` ; TBPS=`expr $T2 - $T1` ; RBPS=`expr $R2 - $R1` ; TKBPS=`expr $TBPS / 1024` ; RKBPS=`expr $RBPS / 1024` ; printf "$DATE,$i,$KBPS,$TKBPS,$RKBPS\\\n" ; fi ; fi ; done'


NODEDIR="/opt/extility/skyline/war/nodenetnic/"


cluster1 ()

	{
			NODENET=$(sshe $i $GETCURRENTTXRX)
			echo $NODENET | sed '/^$/d' >> $NODEDIR$i.csv
	}

cluster2 ()

	{
	                NODENETC2=$(sshe 10.157.16.11 "/root/scripts/nodenet/getnet-speed.sh $i")
        	        echo $NODENETC2 | sed '/^$/d' >> $NODEDIR$i.csv
	}

for i in $NODEIPS
        do      
		if  grep $(date -d"10 minutes ago" +%'H:%M:' | sed 's/\(.\)$/*/')  $NODEDIR$i.csv > /dev/null; then
                        rm -f $NODEDIR$i.csv
			touch $NODEDIR$i.csv
			echo "DATE,nic,speed,txkbyt/s,rxkbyt/s" > $NODEDIR$i.csv
                        cluster1

                else
                        cluster1
                fi

        done


for i in $NODEIPSC2
        do        
                if grep $(date -d"10 minutes ago" +%'H:%M:' | sed 's/\(.\)$/*/')  $NODEDIR$i.csv > /dev/null; then
                        rm -f $NODEDIR$i.csv
			touch $NODEDIR$i.csv
			echo "DATE,nic,speed,txkbyt/s,rxkbyt/s" > $NODEDIR$i.csv
                        cluster2
                else
                        cluster2
                fi

        done

