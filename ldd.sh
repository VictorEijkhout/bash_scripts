#!/bin/bash

function usage () {
    echo "Usage: $0 someexecutable"
}

if [ $# -eq 0 -o "$1" = "-h" ] ; then
    usage && exit 0
fi

script=""
for m in $( module -t list 2>&1 ) ; do
    if [ -z "${m}" ] ; then continue ; fi
    m=${m%%/*} && M=$( echo $m | tr a-z A-Z )
    nam=TACC_${M}_LIB
    eval lib=\${${nam}} 
    if [ ! -z "${lib}" ] ; then 
	script="${script} -e s?${lib}?\${${nam}}?"
    fi
done

ldd $1 \
    | sed ${script}
