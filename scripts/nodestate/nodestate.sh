#!/bin/bash

DATE=$(date +%Y%m%d) 

echo Node State $DATE > /opt/extility/amber/htdocs/flexicp/nodestate/nodestate-$DATE.txt 
/bin/grep 'Setting Node' /var/log/extility/extility-xvpmanager.log >> /opt/extility/amber/htdocs/flexicp/nodestate/nodestate-$DATE.txt

#Cluseter 2
echo Node State $DATE > /opt/extility/amber/htdocs/flexicp/nodestate/cluster2-nodestate-$DATE.txt
sshe 10.0.0.1 /bin/grep \'Setting Node\' /var/log/extility/extility-xvpmanager.log >> /opt/extility/amber/htdocs/flexicp/nodestate/cluster2-nodestate-$DATE.txt
