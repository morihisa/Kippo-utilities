#!/bin/bash
# Kippo honeyfs auto generator based on host os.
# Warning: Use this script is at your own risk.
# 
# created by @k_morihisa 2015/Apr/08
#

DUMMY_USER="test01" # RECOMMEND: change this user name.

if [ $# -ne 1 ]; then
        echo "Usage: $0 Path_To_Kippo_directory"
        exit 1
fi

KIPPO_ROOT="$1"
HONEYFS_PATH="$KIPPO_ROOT/honeyfs"

OWNER_USER=`ls -l $KIPPO_ROOT | grep honeyfs | grep ^d | cut -f 3 -d " "`
OWNER_GROUP=`ls -l $KIPPO_ROOT | grep honeyfs | grep ^d | cut -f 4 -d " "`

UID1000=""
TMPFILE="/tmp/kippo-`date +%s`"

if [ -d $HONEYFS_PATH ]; then
        backup="honeyfs-backup`date +%Y%m%d`.tar.gz"
        tar zcf $backup honeyfs

        if [ $? -eq 0 ]; then
                echo "old honeyfs -> $backup"
        else
                echo "Error: honeyfs backup failed..."
                exit 1
        fi
else
        echo "Error: honeyfs directory not exist."
        exit 1
fi


# /etc/passwd
touch $TMPFILE
while read line
do
	if [ `echo "$line" | cut -f 3 -d ":"` -eq 1000 ];then
		UID1000=`echo "$line" | cut -f 1 -d ":"`
		echo "$line" | sed -e "s/$UID1000/$DUMMY_USER/g" >> $TMPFILE
	else
		echo "$line" | sed -e "s/kippo/${DUMMY_USER}2/g" >> $TMPFILE
	fi
done < /etc/passwd

if [ -z $UID1000 ];then
	echo "Error: uid:1000 not found."
	rm $TMPFILE
	exit 1
fi

mv $TMPFILE ${HONEYFS_PATH}/etc/passwd

# /etc/hostname
HOST_NAME=`grep ^hostname ${KIPPO_ROOT}/kippo.cfg | cut -f 2 -d "=" | tr -d ' '`
echo "$HOST_NAME" > $HONEYFS_PATH/etc/hostname

# /etc/hosts
touch $TMPFILE
while read line
do
        if [ -n "`echo "$line" | grep 127\.0\.1\.1`" ];then
		echo "127.0.1.1 $HOST_NAME" >> $TMPFILE
        else
                echo "$line" >> $TMPFILE
        fi
done < /etc/hosts

mv $TMPFILE ${HONEYFS_PATH}/etc/hosts

# /etc/issue
cat /etc/issue > ${HONEYFS_PATH}/etc/issue

# /etc/shadow
if [ "${USER}" = "root" ];then
	touch $TMPFILE
	while read line
	do
		password=`echo "$line" | cut -f 2 -d ":" | grep -F "$"`
		if [ -n "$password" ];then
			p=`echo "$line" | cut -f 3- -d ":"`
			hash="\$6\$`cat /dev/urandom | tr -dc 'abcdefghkmnprstuvwxyzABCDEFGHJKLMNPRSTUVWXYZ1234567890' | head -c 8`\$`cat /dev/urandom | tr -dc 'abcdefghkmnprstuvwxyzABCDEFGHJKLMNPRSTUVWXYZ1234567890./' | head -c 86`"
			echo "$DUMMY_USER:$hash:$p" >> $TMPFILE
		else
			echo "$line"  | sed -e "s/kippo/${DUMMY_USER}2/g" >> $TMPFILE
		fi
	done < /etc/shadow

	mv $TMPFILE ${HONEYFS_PATH}/etc/shadow
fi

# /etc/group
cat /etc/group | sed -e "s/$UID1000/$DUMMY_USER/g" | sed -e "s/kippo/${DUMMY_USER}2/g" > ${HONEYFS_PATH}/etc/group

# /proc/cpuinfo
cat /proc/cpuinfo > ${HONEYFS_PATH}/proc/cpuinfo

# /proc/meminfo
cat /proc/meminfo > ${HONEYFS_PATH}/proc/meminfo

# /proc/version
cat /proc/version > ${HONEYFS_PATH}/proc/version

chown -R $OWNER_USER:$OWNER_GROUP $HONEYFS_PATH

