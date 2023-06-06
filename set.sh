#!/bin/bash

if [ -f set.txt ]; then
    rm set.txt
fi

read a < input.txt
    domainid=`echo $a | awk '{print $1}' | awk -F. '{print $3"."$2"."$1".in-addr.arpa"}'`
    domainid=`mysql -u root -psagarn -e "use powerdns; select id from domains where name='$domainid';" --skip-column-names`


while read line
do
        ip=`echo $line | awk '{print $1}'`
        domain=`echo $line | awk '{print $2}'`
        # domain=`echo $line | awk '{print $2}' | sed 's/.$//'` # for removing the new line (this issue is only on wsl, it works fine on server with above line)
        ip1=`echo $ip | awk -F. '{print $1}'`
        ip2=`echo $ip | awk -F. '{print $2}'`
        ip3=`echo $ip | awk -F. '{print $3}'`
        ip4=`echo $ip | awk -F. '{print $4}'`
        echo ",$domainid,$ip4.$ip3.$ip2.$ip1.in-addr.arpa,PTR,$domain,86400,0,1548184213" >> set.txt
done < input.txt

mysql --local-infile=1 -u root -psagarn -e "use powerdns; load data local infile '/root/set.txt' into table records fields terminated by ',' lines terminated by '\n';"