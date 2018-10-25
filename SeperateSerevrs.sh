#!bin/bash
for line in $(cat /opt/ipm-test.txt) ; do
echo $line
sleep 1
ttl=$(ping -c 1 $line | grep ttl | awk '{ print $6 }')
#echo $ttl
if [ "$ttl" == "ttl=63" -o "$ttl" == "ttl=64" ]  ; then
echo $line >> /opt/linux.txt
elif [ "$ttl" == "ttl=128" -o  "$ttl" == "ttl=127" ]; then
echo $line >> /opt/windows.txt
else
echo $line >> /opt/shutdown.txt
fi
done
