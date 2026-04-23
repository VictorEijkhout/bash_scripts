#!/bin/bash

function modulelist ()
{
    local compiler=$( module -t list ${TACC_FAMILY_COMPILER} 2>&1 );
    local mpi=$( module -t list ${TACC_FAMILY_MPI} 2>&1 );
    local modules=$( module -t list 2>&1 | grep -v $compiler | grep -v $mpi | sort );
    for m in $compiler $mpi cont $modules;
    do
        if [ $m = "cont" ]; then
            echo "----------------";
        else
            loc=$(module -t show $m 2>&1 | sed -e 's?'${WORK}'?\$\{WORK\}?' );
            echo "$m : $loc";
        fi;
    done
}

commands=$*

if [ $# -eq 1 -a "$1" = "list" ] ; then
    modulelist
else
    eval module ${commands}
fi
