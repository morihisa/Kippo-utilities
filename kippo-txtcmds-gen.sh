#!/bin/bash
# Kippo txtcmds auto generator based on host os.
# Warning: Use this script is at your own risk.
# 
# created by @k_morihisa 2015/Apr/08
#

if [ $# -ne 1 ]; then
	echo "Usage: $0 Path_To_Kippo_directory"
	exit 1
fi

KIPPO_ROOT="$1"
TXTCMDS_PATH="$KIPPO_ROOT/txtcmds"

if [ -d $TXTCMDS_PATH ]; then
	backup="txtcmds-backup`date +%Y%m%d`.tar.gz"
	tar zcf $backup txtcmds

	if [ $? -eq 0 ]; then
		echo "old txtcmds -> $backup"
	else
		echo "Error: txtcmds backup failed..."
		exit 1
	fi
else
	echo "Error: txtcmds directory not exit."
	exit 1
fi

CMDS=("/bin/df" "/bin/dmesg" "/bin/mount" "/sbin/ifconfig" "/usr/bin/free")
for CMD in ${CMDS[@]}
do
	if [ -x $CMD ]; then
		$CMD > ${TXTCMDS_PATH}$CMD
	fi
done

if [ -x /usr/bin/getconf ]; then
	/usr/bin/getconf LONG_BIT > ${TXTCMDS_PATH}/usr/bin/getconf
fi

echo "unlimited" > ${TXTCMDS_PATH}/bin/ulimit

