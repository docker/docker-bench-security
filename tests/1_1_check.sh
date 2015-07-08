# Run tests
THINPOOLDEV=`ps -ef | grep docker | awk '/--storage-opt/ { for (x=1;x<=NF;x++) if ($x~"--storage-opt") print $(x+1) }' | grep thinpooldev | awk -F\= '{print $2}'`
ROOTVOLUME=`df -P | grep " \/$" | awk '{print $1}'`
SEPARATEPARTITION=`grep /var/lib/docker /etc/fstab`

# Verify that somebody didn't put a dummy entry in /etc/fstab and are really 
# using devicemapper
if [ "$SEPARATEPARTITION" ] && [ ! "$THINPOOLDEV" ]; then
	RETVAL=0

# Verify that THINPOOLDEV exists and is not the same as root volume. I am not
# completely sure you could ever do this, but figured it's a safer check
elif [ "$THINPOOLDEV" ] && [ "$THINPOOLDEV" != "$ROOTVOLUME" ]; then
	RETVAL=0
else
	RETVAL=1
fi

return $RETVAL	
