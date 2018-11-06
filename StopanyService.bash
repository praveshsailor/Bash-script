echo "Please enter the Application name which you want to stop"
read id
id=`echo $id | tr '[A-Z]' '[a-z]'`
echo "You want to stop  $id "
sleep 2
ps -ef | grep $id | grep -v grep  | awk '{print $2}'| while read procid
do
kill -9 $procid
done
