ips=(127.0.0.1 172.168.0.1 10.0.0.1)
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
    /usr/bin/ssh -p $port -o StrictHostKeyChecking=no user@$server hostname
# With password
#    /usr/bin/sshpass -p "redhat" ssh -p $port -o StrictHostKeyChecking=no root@$server "bash -s" < /opt/script.sh
    fi
done
  done
