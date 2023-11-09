#!/bin/bash

password="USE_Password"

if [ -f merge.txt ]; then
    rm merge.txt
fi

while read line
do
    ip=`echo $line | awk '{print $1}'`
    domain=`echo $line | awk '{print $2}'`
    ip1=`echo $ip | awk -F. '{print $1}'`
    ip2=`echo $ip | awk -F. '{print $2}'`
    ip3=`echo $ip | awk -F. '{print $3}'`
    ip4=`echo $ip | awk -F. '{print $4}'`

    domainid=`mysql -u root -psagarn -e "use powerdns; select id from records where name='$ip4.$ip3.$ip2.$ip1.in-addr.arpa';" --skip-column-names`
    if [ -z "$domainid" ]; then
        # Entry doesn't exist, create a new entry
        echo "INSERT INTO records (domain_id, name, type, content, ttl, prio, change_date) VALUES ((SELECT id FROM domains WHERE name='$ip3.$ip2.$ip1.in-addr.arpa'), '$ip4.$ip3.$ip2.$ip1.in-addr.arpa', 'PTR', '$domain', 86400, 0, UNIX_TIMESTAMP(NOW()));" >> merge.txt
    else
        # Entry exists, update the entry
        echo "UPDATE records SET content='$domain' WHERE name='$ip4.$ip3.$ip2.$ip1.in-addr.arpa';" >> merge.txt
    fi

done < input.txt

mysql --user="root" --database="powerdns" --password="$password" < "/root/merge.txt"
