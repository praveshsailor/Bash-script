ips=(192.168.100.200 10.5.7.47 10.5.6.251)
# ports=(22  443 80)
# for server in "${ips[@]}"
# do
#   for port in "${ports[@]}"

for server in "${ips[@]}"
do
  for port in 22 49226
  do
    if [ $(nc 2>/dev/null -vz $server $port; echo $?) -eq 0 ] ; then
      echo $server $port
# With out password with ssh key
    /usr/bin/ssh -p $port -o StrictHostKeyChecking=no issteam@$server hostname
# With password
#    /usr/bin/sshpass -p "redhat" ssh -p 22 -o StrictHostKeyChecking=no root@$line "bash -s" < /opt/2.sh
    fi
done
  done
