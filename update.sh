#!/bin/bash

if [ -f replace.txt ]; then
    rm replace.txt
fi

while read line
do      
        ip=`echo $line | awk '{print $1}'`
        domain=`echo $line | awk '{print $2}'`
        # domain=`echo $line | awk '{print $2}' | sed 's/.$//'` # for removing the new line (this issue is only on wsl, it works fine on server with above line)
        ip1=`echo $ip | awk -F. '{print $1}'`
        ip2=`echo $ip | awk -F. '{print $2}'`
        ip3=`echo $ip | awk -F. '{print $3}'`
        ip4=`echo $ip | awk -F. '{print $4}'`
        echo "UPDATE records SET content='$domain' WHERE name='$ip4.$ip3.$ip2.$ip1.in-addr.arpa';" >> replace.txt
done < input.txt

mysql --user="root" --database="powerdns" --password="sagarn" < "/root/replace.txt"