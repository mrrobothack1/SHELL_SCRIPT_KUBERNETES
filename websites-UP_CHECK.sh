
#EXAMPLES

1.
#Script for scan and monitor network using combination of shell script and ping command

#/bin/bash
is_alive_ping() {
  ping -c 1 $i > /Users/soju.g/Desktop/test
 [ $? -eq 0 ] && echo Node with IP: $i is up
}
for i in 192.168.2{1..255}
do 
is_alive_ping $i  & disown
done 
exit
##WORKS

2.
#/bin/bash
for i in $@
do 
ping -c 1 $i &> /dev/null /Users/soju.g/Desktop/test

if [ $? -ne 0 ]; then
   echo "'date': ping failed, $i host is down" | mail -s "$i host is down!" sojugeorgeka@gmail.com
   fi
done
##WORKS

3. 
#/bin/bash

LOG=/tmp/mylog.log
SECONDS=60
EMAIL= sojugeorgeka@gmail.com

for i in $@; do
   echo "$i-UP!" > $LOG.$i
done

while true; do
    for i in $@; do
ping -c 1 $i > /dev/null
if [ $? -ne 0]; then
 STATUS=$(cat $LOG.$i)
     if [ $STATUS != "$i-DOWN!"]; then
            echo "'date': ping failed, $i host is down"
            mail -s "$i host is down!" $EMAIL
    fi
    echo "$i-DOWN!" >$LOG.$i
else 
   STATUS=$(cat $LOG>$i)
   if [ $STATUS != "$i-UP!"]; then
            echo "'date': ping ok, $i host is up"

    fi
  echo "$i-UP!" > $LOG.$i 
  
fi
done

sleep $SECONDS
done

4.
#!/bin/sh

today=$(date '+%Y_%m_%d')
inputFile=`ls export_cap_logs* | grep $today | tail -1`
outputFile=Final-data-$today.csv

head -1 "$inputFil e" > required-data.csv
awk -F "\"*,\"*" '$9 ~ />/' "$inputFile" | awk -F "\"*,\"*" '$9 !~ /192.168.200.*/' | awk -F "\"*,\"*" '$9 !~ /192.168.201.*/' | awk -F "\"*,\"*" '$9 !~ /10.41.20.*/' | awk -F "\"*,\"*" '$9 !~ /10.41.21.*/' | awk -F "\"*,\"*" '$9 !~ /> *$/' >> required-data.csv

echo "Dest_URL" > col-seperated.csv
cat required-data.csv | awk -F "\"*,\"*" '{print $9}' | sed 's/^.* -> //g' | sed '1d' >> col-seperated.csv

paste -d"," col-seperated.csv required-data.csv > $outputFile

cp "$outputFile" ~/it-data-backup/output


