#!/bin/bash
#This program send email warining to user when disk is almost of capacity
#Disk space usage
DISK_USAGE=`df -h .|grep / | awk '{print $5}'|sed 's/%//g'`

#FileSystem Directory
FILE_DIRECTORY=`df -hT . | grep / | awk '{ print $2}'`

# Didplay FileSystem Usage
DISPLAY=`df -hT . `

#holds default capacity to alert emails warning
DEFAULT=60

#holds capacity parameter
CAPACITY=$2

#holds username parameter
USERNAME=$1

if [ $USERNAME ]
  then
      echo "THIS IS YOUR SYSTEM USAGE: "
      echo "$DISPLAY"
  else
      echo "No USERNAME entered!"
      echo "Enter username as first parameter"
      exit 1
 fi
#checking if capacity exist
if [ ! $CAPACITY ]
  then
    echo "No capacity is entered; Using default capacity value of 60"
    CAPACITY=$DEFAULT
  fi

#Compare disk usage and the threshold
if [ $DISK_USAGE -ge $CAPACITY ] && [ $DISK_USAGE -ge 90 ]
    then
    mailx -s "Critical Warning: the file system $FILE_DIRECTORY is greater\
    than or equal to 90% capacity" $USERNAME@cyberserver.uml.edu
    "SYSTEM USAGE IS->:"
    $DISPLAY
    exit 2

elif [ $DISK_USAGE -ge $CAPACITY ] && [ $DISK_USAGE -lt 90 ]
     then
     mailx -s "Warning: the file system $FILE_DIRECTORY is\
     above $DEFAULT% used" $USERNAME@cyberserver.uml.edu
     "SYSTEM USAGE->->:"
      $DISPLAY
      exit 3
    else
        echo "$FILE_DIRECTORY IS $DISK_USAGE% AND IT'S UNDER CAPACITY USAGE"
fi
