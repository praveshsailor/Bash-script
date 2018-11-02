#!/bin/bash
JAVA_CHECK=`java -version 2>&1`
if [[ "$JAVA_CHECK" == *"Java(TM) SE Runtime Environment"* ]]; then
   echo "Java is already installed!"
   echo
   java -version
   echo
   exit 0
fi
##############################
java8=/usr/lib/jvm/java-8-oracle
java7=/usr/lib/jvm/java-7-oracle
java6=/usr/lib/jvm/java-7-oracle

if [ "$#" = 0 ]

then
echo "Usage:   $0 [options] jdk-archive-file.tar.gz"

exit 1

fi
JDK_ARCHIVE=$1

#Check if the script is running with root permissions
if [ `id -u` -ne 0 ]; then
   echo "The script must be run as root! (you can use sudo)"
   exit 1
fi

echo $JDK_ARCHIVE

# Verify the provided JDK archive file
#   Is the file provided?
#if [ -z "$JDK_ARCHIVE" ]; then
#   display_usage
#   exit 1
#fi


#   Is the file existing?
if [ ! -f $JDK_ARCHIVE ]; then
   echo "Provided file does not exist: $JDK_ARCHIVE"
   echo
   exit 1
fi

#   Is the file a valid archive?
echo -n "Validating the archive file... "
gunzip -t $JDK_ARCHIVE 2>> /dev/null
if [ $? -ne 0  ]; then
   echo "FAILED"
   echo
   echo "Provided file is not a valid .tar.gz archive: $JDK_ARCHIVE"
   echo
   echo "Be sure to download Linux .tar.gz package from the Oracle website"
   echo $ORACLE_DOWNLOAD_LINK
   echo
   exit 1
fi

#################

#   Is the file containing JDK?
#   Also obtain JDK version using the occassion
JDK_VERSION=`tar -tf $JDK_ARCHIVE | egrep '^[^/]+/$' | head -c -2` 2>> /dev/null
#if [[ $JDK_VERSION != "java"* ]]; then
if [[ $JDK_VERSION != "jdk"* ]]; then
   echo "FAILED"
   echo
   echo "The provided archive does not contain JDK: $JDK_ARCHIVE"
   echo
   echo "Please provide valid JDK archive from Oracle Website"
   echo $ORACLE_DOWNLOAD_LINK
   echo
   exit 1
fi
echo "OK"

# All checks are done at this point
# Begin Java installation

# Extract the archive
echo -n "Extracting the archive... "
#JDK_LOCATION=/usr/lib/jvm/$JDK_VERSION
mkdir -p /usr/lib/jvm
tar -xf $JDK_ARCHIVE -C /usr/lib/jvm
#########
if [ -d /usr/lib/jvm/jdk1.8* ] ; then
/usr/bin/mv /usr/lib/jvm/jdk1.8* $java8
JDK_LOCATION=$java8
elif [ -d /usr/lib/jvm/jdk1.7* ] ; then
/usr/bin/mv /usr/lib/jvm/jdk1.7* $java7
JDK_LOCATION=$java7
elif [ -d /usr/lib/jvm/jdk1.6* ] ; then
/usr/bin/mv /usr/lib/jvm/jdk1.6* $java6
JDK_LOCATION=$java6
fi

echo "OK"


# Update system to use Oracle Java by default
echo -n "Updating system alternatives... "
update-alternatives --install "/usr/bin/java" "java" "$JDK_LOCATION/jre/bin/java" 1 >> /dev/null
update-alternatives --install "/usr/bin/javac" "javac" "$JDK_LOCATION/bin/javac" 1 >> /dev/null
update-alternatives --set java $JDK_LOCATION/jre/bin/java >> /dev/null
update-alternatives --set javac $JDK_LOCATION/bin/javac >> /dev/null
echo "OK"

# Verify and exit installation
echo -n "Verifying Java installation... "
JAVA_CHECK=`java -version 2>&1`
if [[ "$JAVA_CHECK" == *"Java(TM) SE Runtime Environment"* ]]; then
   echo "OK"
   echo
   echo "Java is successfully installed!"
   echo
   java -version
   echo
   exit 0
else
   echo "FAILED"
   echo
   echo "Java installation failed!"
   echo
   exit 1
fi

