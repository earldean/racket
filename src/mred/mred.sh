#!/bin/sh

# This script picks the right binary for a mutli-platform
#  configuration

if [ "$PLTHOME" = '' ] ; then
  PLTHOME=/usr/local/lib/plt
  export PLTHOME
fi

SYS=`${PLTHOME}/bin/archsys`

exec ${PLTHOME}/.bin/${SYS}/mred ${1+"$@"}

