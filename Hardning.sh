#!/bin/bash
##############################
SSHCONF=/etc/ssh/sshd_config
WHEELSU=/etc/pam.d/su
#############################
/usr/bin/cp /etc/fstab /root/
/usr/bin/cp $SSHCONF /root/
/usr/bin/cp $WHEELSU  /root/
####################Add normal user for sudo access
echo "***Create additional user***"
read -p "Please enter additional usre name : " user
egrep "^$user" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
  echo "$user exists!"
else
useradd "$user" ; usermod -G wheel "$user"
/usr/bin/chage -m 0 -M 99999 -I -1 -E -1 "$user"
read -s -p "Enter password : " pass
echo "$pass" | passwd --stdin "$user"
fi
#############################################################
#/etc/fstab file entry function
############################################################
FSTAB () {
grep  "/var/tmp" /etc/fstab
if [ `echo $?`  != 0 ] ; then
echo "/tmp                    /var/tmp                none    rw,noexec,nosuid,nodev,bind  0  0" >> /etc/fstab
fi
###############################################################
# Tmp=$(grep -i tmp /etc/fstab | awk '{print $1}' | cut -d/ -f4)
Tmp=$(df | grep /tmp | awk '{print $1}'| cut -d/ -f4)
Usr=$(df | grep /usr | awk '{print $1}'| cut -d/ -f4)
Var=$(df | grep /var | awk '{print $1}'| cut -d/ -f4)
Home=$(df | grep /home | awk '{print $1}'| cut -d/ -f4)
###############################################################
sed -i  "/$Var/ s/defaults/noexec,nosuid,nodev/g"  /etc/fstab
sed -i  "/$Tmp/ s/defaults/rw,noexec,nosuid,nodev/g"  /etc/fstab
sed -i  "/$Usr/ s/defaults/nodev/g"  /etc/fstab
sed -i  "/$Home/ s/defaults/noexec,nosuid,nodev/g"  /etc/fstab
#################################################################
}
#It will change the fstab file if the partition created in LVM
if [ "$(/usr/sbin/vgdisplay | grep -q lvm)" == "0"  ] ; then
FSTAB
fi
#############################
############################
###Add # before  nameserver #
sed -i '/^nameserver/ s/^/#/g' /etc/resolv.conf
sed -i '/^nameserver / s/^/#/g' /etc/resolv.conf
##################################################
###Remove  Current nameservers #
sed -i '/#nameserver/d' /etc/resolv.conf
sed -i '/#nameserver/d' /etc/resolv.conf
###################################################
### If you have any custom Nameservers Upadte here########### 
echo -e "nameserver    8.8.8.8" >>  /etc/resolv.conf
echo -e "nameserver    8.8.4.4"       >>  /etc/resolv.conf
##################################################
##Selinux disable
##################################################
sed -i '/^SELINUX/ s/^/#/g' /etc/sysconfig/selinux
##################################################
sed -i '/#SELINUX=enforcing/a SELINUX=disabled' /etc/sysconfig/selinux
###################################################
sed -i '/#SELINUX/d' /etc/sysconfig/selinux
###################################################
#Password Policy
###################################################
###PUT HASH before PASS_MAX_DAYS line#######
sed -i '/^PASS_MAX_DAYS/ s/^/#/g' /etc/login.defs
sed -i '/^PASS_MIN_DAYS/ s/^/#/g' /etc/login.defs
sed -i '/^PASS_MIN_LEN/ s/^/#/g' /etc/login.defs
sed -i '/^PASS_WARN_AGE/ s/^/#/g' /etc/login.defs
###add a new line as PASS_MAX_DAYS 90 line#######
sed -i '/#PASS_MAX_DAYS/a PASS_MAX_DAYS 90' /etc/login.defs
sed -i '/#PASS_MIN_DAYS/a PASS_MIN_DAYS 1' /etc/login.defs
sed -i '/#PASS_MIN_LEN/a PASS_MIN_LEN 8' /etc/login.defs
sed -i '/#PASS_WARN_AGE/a PASS_WARN_AGE 10' /etc/login.defs
###Remove the  HASH  PASS_MAX_DAYS line #######
sed -i '/#PASS_MAX_DAYS/d' /etc/login.defs
sed -i '/#PASS_MIN_DAYS/d' /etc/login.defs
sed -i '/#PASS_MIN_LEN/d' /etc/login.defs
sed -i '/#PASS_WARN_AGE/d' /etc/login.defs
##############SU SETTINGS########
sed -i '/pam_wheel.so use_uid/ s/#auth/auth/g' $WHEELSU
##################################
######## SSH Hardings #########
sed -i '/^AllowTcpForwarding yes/ s/^/#/g' $SSHCONF
sed -i '/#AllowTcpForwarding yes/a AllowTcpForwarding no' $SSHCONF
sed -i '/#AllowTcpForwarding yes/d' $SSHCONF
#####ADDED # SINE BEFORE THE LINE ##############
sed -i '/^LogLevel/ s/^/#/g' $SSHCONF
##### ADD LogLevel DEBUG as new Line##########
sed -i '/#LogLevel INFO/a LogLevel DEBUG' $SSHCONF
##### Remove #LogLevel INFO ##########
sed -i '/#LogLevel/d' $SSHCONF
#############################################################
crontab  -l ; echo "0 5 * * * /usr/sbin/aide --check" | crontab -
##########################
#####ADDED # SINE BEFORE THE LINE ##############
sed -i '/^X11Forwarding/ s/^/#/g' $SSHCONF
sed -i '/#X11Forwarding yes/a X11Forwarding no' $SSHCONF
sed -i '/#X11Forwarding/d' $SSHCONF
#######################MaxAuthTries##############
#####ADDED # SINE BEFORE THE LINE ##############
sed -i '/^MaxAuthTries/ s/^/#/g' $SSHCONF
sed -i '/#MaxAuthTries 	6/a MaxAuthTries 6' $SSHCONF
sed -i '/#MaxAuthTries/d' $SSHCONF
########################################################################
sed -i '/^Banner/ s/^/#/' $SSHCONF
echo "Banner /etc/issue" >> $SSHCONF
#####ADDED # SINE BEFORE THE LINE ##############
sed -i '/^Port/ s/^/#/g' $SSHCONF
sed -i '/#Port 22/a Port 2222' $SSHCONF
#############################################################
firewall-cmd --permanent --zone=public --add-port=2222/tcp
firewall-cmd --reload
#############################################
service sshd reload
########################################################################
yum remove setroubleshoot -y
yum remove mcstrans -y
yum remove telnet-server -y
yum remove telnet -y
yum remove rsh-server -y
yum remove rsh -y
yum remove ypbind -y
yum remove ypserv	-y
yum remove tftp -y
yum remove tftp-server -y
yum remove talk -y
yum remove talk-server v
yum remove xinetd -y
yum remove wget -y
#############################################################
yum install sysstat -y
yum install aide -y
yum install rsync -y
yum install ntp ntpdate -y
yum install screen -y
yum install cronie-anacron -y
yum install net-tools -y
#############################################################
chkconfig chargen-dgram off
chkconfig chargen-stream off
chkconfig daytime-dgram off
chkconfig daytime-stream off
chkconfig tcpmux-server off
##############PERMISSION ###########
chmod 0700 /usr/bin/curl
chmod 700 /usr/bin/telnet
#############################################################
chown root:root /boot/grub2/grub.cfg
chmod og-rwx /boot/grub2/grub.cfg
#############################################################
# grep "hard core" /etc/security/limits.conf
# * hard core 0
# sysctl fs.suid_dumpable
# fs.suid_dumpable = 0
echo -e  hard core >> /etc/security/limits.conf
#############################################################
yum remove dhcp -y
yum remove openldap-clients -y
yum remove openldap-servers -y
yum remove bind -y
yum remove vsftpd -y
yum remove httpd -y
yum remove dovecot -y
yum remove samba -y
yum remove squid -y
yum remove net-snmp -y
yum remove  libvirt-daemon qemu-kvm-common qemu-guest-agent gnome-dictionary libreoffice-*  -y
yum remove gnome-weather gnome-contacts cheese gnome-video-effects  -y
#############################################################
systemctl disabled cups
systemctl disable nfslock
systemctl disable rpcgssd
systemctl disable rpcbind
systemctl disable rpcidmapd
systemctl disable rpcsvcgssd
#Disable / Enable
systemctl enable sysstat.service
systemctl disable xinetd
systemctl disable rexec
systemctl disable rsh
systemctl disable rlogin
systemctl disable ypbind
systemctl disable tftp
systemctl disable certmonger
systemctl disable cgconfig
systemctl disable cgred
systemctl disable cpuspeed
systemctl disable kdump
systemctl disable mdmonitor
systemctl disable messagebus
systemctl disable netconsole
systemctl disable ntpdate
systemctl disable oddjobd
systemctl disable portreserve
systemctl disable qpidd
systemctl disable quota_nld
systemctl disable rdisc
systemctl disable rhnsd
systemctl disable rhsmcertd
systemctl disable saslauthd
systemctl disable smartd
systemctl disable sysstat
systemctl disable atd
systemctl disable nfslock
systemctl disable named
systemctl disable httpd
systemctl disable dovecot
systemctl disable squid
systemctl disable snmpd
systemctl disable avahi-daemon.service
########################################################
systemctl enable irqbalance
systemctl enable crond
systemctl enable psacct
##########################################################
echo "Disable Interface Usage of IPv6"
cp -ar /etc/sysconfig/network /etc/sysconfig/network_bk
##########################################################
echo "NETWORKING_IPV6=no"  >> /etc/sysconfig/network
echo "IPV6INIT=no" >> /etc/sysconfig/network
##############Disable Zeroconf Networking#########################
##Zeroconf network typically occurs when you fail to get an address via DHCP, the interface will be
##assigned a 169.254.0.0 address.
echo "NOZEROCONF=yes" >> /etc/sysconfig/network
####Disable IPv6 Support Automatically Loading##
echo "options ipv6 disable=1" >> /etc/modprobe.d/disabled.conf
#############################################################
service postfix restart
#############################################################
/usr/bin/cp  /etc/sysctl.conf /etc/sysctl.conf_bk
/usr/bin/rm -f /etc/sysctl.conf
touch /etc/sysctl.conf
echo -e  kernel.randomize_va_space = 2  >> /etc/sysctl.conf
echo -e  net.ipv4.ip_forward=0  >> /etc/sysctl.conf
echo -e  net.ipv4.conf.all.send_redirects=0	 >> /etc/sysctl.conf
echo -e  net.ipv4.conf.default.send_redirects=0 	 >> /etc/sysctl.conf
echo -e  net.ipv4.conf.all.accept_source_route=0 	 >> /etc/sysctl.conf
echo -e  net.ipv4.conf.default.accept_source_route=0 	 >> /etc/sysctl.conf
echo -e  net.ipv4.conf.all.log_martians=1 		 >> /etc/sysctl.conf
echo -e  net.ipv4.conf.default.log_martians=1 	 >> /etc/sysctl.conf
echo -e # don't respond to a ping to the broadcast address  >> /etc/sysctl.conf
echo -e  net.ipv4.icmp_echo_ignore_broadcasts=1  >> /etc/sysctl.conf
echo -e  net.ipv4.icmp_ignore_bogus_error_responses=1		 >> /etc/sysctl.conf
echo -e  net.ipv4.conf.all.rp_filter=1 	 >> /etc/sysctl.conf
echo -e  net.ipv4.conf.default.rp_filter=1	 >> /etc/sysctl.conf
echo -e  net.ipv4.tcp_syncookies=1		 >> /etc/sysctl.conf
echo -e  net.ipv6.conf.all.accept_ra=0 	 >> /etc/sysctl.conf
echo -e  net.ipv6.conf.default.accept_ra=0		 >> /etc/sysctl.conf
echo -e  net.ipv6.conf.all.accept_redirects=0 		 >> /etc/sysctl.conf
echo -e  net.ipv6.conf.default.accept_redirects=0		 >> /etc/sysctl.conf
echo -e  net.ipv4.route.flush=1		 >> /etc/sysctl.conf
echo -e # disable IPv6 for all network interfaces >> /etc/sysctl.conf
echo -e  net.ipv6.conf.all.disable_ipv6=1			 >> /etc/sysctl.conf
echo -e net.ipv4.conf.all.accept_redirects=0 	>> /etc/sysctl.conf
echo -e	net.ipv4.conf.default.accept_redirects=0	>> /etc/sysctl.conf
echo -e	net.ipv4.conf.all.secure_redirects=0		>> /etc/sysctl.conf
echo -e	net.ipv4.conf.default.secure_redirects=0	>> /etc/sysctl.conf
#############################################################
/bin/chmod 644 /etc/hosts.allow
/bin/chmod 644 /etc/hosts.deny
#############################################################
/usr/bin/cp /etc/modprobe.d/CIS.conf /root
/usr/bin/rm -f /etc/modprobe.d/CIS.conf
##############################################################
echo "install rds /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install sctp /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install tipc /bin/true" >> /etc/modprobe.d/CIS.conf
#############################################################
systemctl enable firewalld
systemctl enable rsyslog
systemctl enable auditd
systemctl enable gdm.service
#############################################################
#Add the following lines to the /etc/audit/auditd.conf file.
#space_left_action = email
#action_mail_acct = root
#admin_space_left_action = halt
#max_log_file_action = keep_logs
#grep "linux" /boot/grub2/grub.cfg
#GRUB_CMDLINE_LINUX="audit=1"
#############################################################
/usr/bin/mv /etc/audit/rules.d/audit.rules /etc/audit/rules.d/audit.rules.bk
/usr/bin/touch /etc/audit/rules.d/audit.rules
#Add the following lines to thed file.
echo -e -a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change  >> /etc/audit/rules.d/audit.rules
echo -e	-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change  >> /etc/audit/rules.d/audit.rules
echo -e	-a always,exit -F arch=b64 -S clock_settime -k time-change  >> /etc/audit/rules.d/audit.rules
echo -e	-a always,exit -F arch=b32 -S clock_settime -k time-change  >> /etc/audit/rules.d/audit.rules
echo -e	-w /etc/group -p wa -k identity  >> /etc/audit/rules.d/audit.rules
echo -e	-w /etc/passwd -p wa -k identity  >> /etc/audit/rules.d/audit.rules
echo -e	-w /etc/gshadow -p wa -k identity  >> /etc/audit/rules.d/audit.rules
echo -e	-w /etc/shadow -p wa -k identity 	 >> /etc/audit/rules.d/audit.rules
echo -e	-w /etc/security/opasswd -p wa -k identity >> /etc/audit/rules.d/audit.rules
echo -e	-w /etc/localtime -p wa -k time-change 	 >> /etc/audit/rules.d/audit.rules
echo -e	-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale   >> /etc/audit/rules.d/audit.rules
echo -e	-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale 	 >> /etc/audit/rules.d/audit.rules
echo -e	-w /etc/issue -p wa -k system-locale -w /etc/issue.net -p wa -k system-locale  >> /etc/audit/rules.d/audit.rules
echo -e	-w /etc/hosts -p wa -k system-locale  >> /etc/audit/rules.d/audit.rules
echo -e	-w /etc/sysconfig/network -p wa -k system-locale	 >> /etc/audit/rules.d/audit.rules
echo -e	-w /etc/selinux/ -p wa -k MAC-policy	 >> /etc/audit/rules.d/audit.rules
echo -e	-w /var/log/faillog -p wa -k logins 	 >> /etc/audit/rules.d/audit.rules
echo -e	-w /var/log/lastlog -p wa -k logins 	 >> /etc/audit/rules.d/audit.rules
echo -e	-w /var/log/tallylog -p wa -k logins	 >> /etc/audit/rules.d/audit.rules
echo -e	-w /var/run/utmp -p wa -k session 			 >> /etc/audit/rules.d/audit.rules
echo -e	-w /var/log/wtmp -p wa -k session 	 >> /etc/audit/rules.d/audit.rules
echo -e	-w /var/log/btmp -p wa -k session	 >> /etc/audit/rules.d/audit.rules
echo -e	-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod  >> /etc/audit/rules.d/audit.rules
echo -e	-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod	 >> /etc/audit/rules.d/audit.rules
echo -e	-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod  >> /etc/audit/rules.d/audit.rules
echo -e	-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod   >> /etc/audit/rules.d/audit.rules
echo -e	-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod  >> /etc/audit/rules.d/audit.rules
echo -e	-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod   >> /etc/audit/rules.d/audit.rules
echo -e	-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access	 >> /etc/audit/rules.d/audit.rules
echo -e	-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access 	 >> /etc/audit/rules.d/audit.rules
echo -e	-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access	 >> /etc/audit/rules.d/audit.rules
echo -e	-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access	 >> /etc/audit/rules.d/audit.rules
echo -e	-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts   >> /etc/audit/rules.d/audit.rules
echo -e	-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts		 >> /etc/audit/rules.d/audit.rules
echo -e	-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete   >> /etc/audit/rules.d/audit.rules
echo -e	-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete  >> /etc/audit/rules.d/audit.rules
echo -e	-w /etc/sudoers -p wa -k scope	 >> /etc/audit/rules.d/audit.rules
echo -e	-w /var/log/sudo.log -p wa -k actions	 >> /etc/audit/rules.d/audit.rules
echo -e	-w /sbin/insmod -p x -k modules 	 >> /etc/audit/rules.d/audit.rules
echo -e	-w /sbin/rmmod -p x -k modules 		 >> /etc/audit/rules.d/audit.rules
echo -e	-w /sbin/modprobe -p x -k modules	 >> /etc/audit/rules.d/audit.rules
echo -e	-a always,exit -F arch=b64 -S init_module -S delete_module -k modules	 >> /etc/audit/rules.d/audit.rules
echo -e	-e 2  >> /etc/audit/rules.d/audit.rules
#############################################################
systemctl enable crond
#############################################################
chown root:root /etc/anacrontab
chmod og-rwx /etc/anacrontab
chown root:root /etc/cron.hourly /etc/cron.weekly /etc/cron.monthly
chmod og-rwx /etc/cron.hourly /etc/cron.weekly /etc/cron.monthly
chown root:root /etc/cron.d
chmod og-rwx /etc/cron.d
#############################################################
rm /etc/at.deny
#############################################################
touch /etc/at.allow
chown root:root /etc/at.allow
chmod og-rwx /etc/at.allow
#############################################################
/bin/rm /etc/cron.deny
/bin/rm /etc/at.deny
chmod og-rwx /etc/cron.allow
chmod og-rwx /etc/at.allow
chown root:root /etc/cron.allow
chown root:root /etc/at.allow
#############################################################
usermod -g 0 root
#############################################################
#How to set umask umask 77
#############################################################
useradd -D -f 35
#############################################################
touch /etc/motd
echo "WARNING : USE OF THIS SYSTEM IS RESTRICTED AND MONITORED." > /etc/issue
############################################################
/bin/chown root:root /etc/motd
/bin/chmod 644 /etc/motd
/bin/chown root:root /etc/issue
/bin/chmod 644 /etc/issue
/bin/chown root:root /etc/issue.net
/bin/chmod 644 /etc/issue.net
#############################################################
/bin/chmod 644 /etc/passwd
/bin/chmod 000 /etc/shadow
/bin/chmod 000 /etc/gshadow
/bin/chmod 644 /etc/group
/bin/chown root:root /etc/passwd
/bin/chown root:root /etc/gshadow
/bin/chown root:root /etc/group
/bin/chmod 600 $SSHCONF
/bin/chown root:root $SSHCONF
#############################################################
#Add the following line to the /etc/sysconfig/init file.
echo -e "#The umask influences the permissions assigned to files created by a process at run time." >> /etc/sysconfig/init
echo -e umask 027 >> /etc/sysconfig/init
#Change the default runlevel to multi user without X:
#cd /etc/systemd/system/
#unlink default.target
#ln -s /usr/lib/systemd/system/multi-user.target default.target
#sudo systemctl set-default graphical.target

#############################################################
echo '30 * * * * root /usr/sbin/ntpd -q -u ntp:ntp' > /etc/cron.d/ntpd
#################SSH KEY########
rm -rf /root/.ssh/authorized_keys
mkdir -p /root/.ssh/
##############
echo '##Enetr your SSH-KEY for access###' > /root/.ssh/authorized_keys
##############
chmod 700  /root/.ssh/
chmod 400 /root/.ssh/authorized_keys
###################
/usr/sbin/aide -i
#####################
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
############################
mkdir -p /home/$user/.ssh/
echo '##Enetr your SSH-KEY for access###' >  /home/$user/.ssh/authorized_keys
chmod 700  /home/$user/.ssh
chmod 400 /home/$user/.ssh/authorized_keys
sudo chown $user:$user /home/$user/.ssh -R
###############################################
/usr/bin/cp -ar /etc/sudoers /root/
############################
## Limited SUDO ACCESS FOR The user##
grep $user /etc/sudoers
if [ `echo $?`  != 0 ] ; then
echo "Cmnd_Alias DELEGATING = /bin/chown, /bin/chmod, /usr/sbin/reboot, /usr/bin/sudo, /bin/sh, /bin/bash, /bin/kill, /usr/bin/rsync" >> /etc/sudoers
echo "$user ALL=(ALL) NOPASSWD:DELEGATING" >> /etc/sudoers
fi
##################################################
echo "Server reboot is in-process press ctrl + C to cancel"
sleep 15
reboot
