#!/bin/bash
DATE=$(date "+%Y-%m-%dT%H:%M:%S")
UPSAA4= 10.0.0.1
UPSAA5= 10.0.0.2
UPSBA5= 10.0.0.3
PDU2A7= 10.0.0.4
PDU3A7= 10.0.0.5
CSV=upsload.csv

UPSDIR="/opt/extility/skyline/war/rackload/"

		touch $UPSDIR$CSV
		if  ! grep -q 'DATE,RACK,AMPERS' $UPSDIR$CSV ; then

			sed -i -e '1 i\DATE,RACK,AMPERS' $UPSDIR$CSV ; 
		fi

#Get Amps for upsAracka4.lvi
UPSAA4AMP=$(snmpget -c public -v 1 $UPSAA4 .1.3.6.1.4.1.318.1.1.1.4.2.4.0 | awk  '{ print $4 }')

TOTALAMPSA4=$UPSAA4AMP

echo $DATE,A4,$TOTALAMPSA4 >> $UPSDIR$CSV

#Get Amps for ups[AB]racka5.lvi
UPSAA5AMP=$(snmpget -c public -v 1 $UPSAA5 .1.3.6.1.4.1.318.1.1.1.4.2.4.0 | awk  '{ print $4 }')
UPSBA5AMP=$(snmpget -c public -v 1 $UPSBA5 .1.3.6.1.4.1.318.1.1.1.4.2.4.0 | awk  '{ print $4 }')

TOTALAMPSA5=$(($UPSAA5AMP +  $UPSBA5AMP))

echo $DATE,A5,$TOTALAMPSA5 >> $UPSDIR$CSV

#Get Amps for pdu[23]racka7.lvi
PDU2A7AMP=$( snmpget -v 1 -c public $PDU2A7 .1.3.6.1.4.1.318.1.1.12.2.3.1.1.2.1 | awk  '{ print $4 }')
PDU3A7AMP=$( snmpget -v 1 -c public $PDU3A7 .1.3.6.1.4.1.318.1.1.12.2.3.1.1.2.1 | awk  '{ print $4 }')

TOTALAMPSA7=$(echo "scale=0 ; ($PDU2A7AMP + $PDU3A7AMP)/10" | bc -l )

echo $DATE,A7,$TOTALAMPSA7 >> $UPSDIR$CSV

exit 0 
