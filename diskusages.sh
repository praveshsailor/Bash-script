##!/bin/bash
SSHCMD="/usr/bin/ssh -q -o StrictHostKeyChecking=no"  ## Need ssh Key Or we can put the password
echo "Hi Team," > /tmp/mail_input
echo "" >> /tmp/mail_input
echo -e " Please find the filesystem utilization report for below servers.\n" >> /tmp/mail_input
echo "*********************************************************" >> /tmp/mail_input
echo "*                FILESYSTEM UTILIZATION                 *" >> /tmp/mail_input
echo "*********************************************************" >> /tmp/mail_input
echo "" >> /tmp/mail_input
##########################################################################
for i in `cat /root/disk49226.txt | grep -v '#'`  ### Server IP address file location
do
  for port in 22 2222 # Enter the All ssh ports
  do
    # if [ $(nc 2>/dev/null -vz $i $port; echo $?) -eq 0 ] ; then
        if echo 2>/dev/null > /dev/tcp/"$i"/"$port" ; then   #Checking for server assostied ssh port
name=$($SSHCMD -p $port username@$i hostname)
$SSHCMD -p $port username@$i df -h | grep -e [80,90][0-9]% -e 100% | grep -iv run | grep -iv Peoplestrong | awk '{print $5}' > /tmp/test_app
used=`du /tmp/test_app | awk '{print $1}'`
###########################################################
if [ $used -ne 0 ]
then
echo "*************************" >> /tmp/mail_input
#echo "HOSTNAME:${bold}$name${normal}" >> /tmp/mail_input
echo "HOSTNAME:$name" >> /tmp/mail_input
echo "IP ADDRESS:$i" >> /tmp/mail_input
echo "*************************" >> /tmp/mail_input
echo "%USED     FILESYSTEM" >> /tmp/mail_input
$SSHCMD -p $port username@$i df -h | grep -e [80,90][0-9]% -e 100% | grep -iv run | grep -iv Peoplestrong | awk '{print $5,"     ",$6}' >> /tmp/mail_input
echo "*************************" >> /tmp/mail_input
echo "" >> /tmp/mail_input
fi
fi
done
done
################################################################################
cat /tmp/mail_input | grep -e [80,90][0-9]% -e 100% > /tmp/used1.txt
################################################################################
used2=`du /tmp/used1.txt | awk '{print $1}'`
if [ $used2 -ne 0 ]
then
echo -e "\nNote: It is an auto generated alert mail" >> /tmp/mail_input
echo -e "\nThanks and Regards,\nLinuxadmin,\Company Name" >> /tmp/mail_input
mail -s "(Alert: Filesystem Utilization High (Above 80%) )" praveshsailor@gmail.com  < /tmp/mail_input #Replace Email id
fi
##################################End of the script#############################################
