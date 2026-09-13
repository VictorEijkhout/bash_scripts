####
#### This file needs to be sourced
#### to add useful shell functions.
####

#
# functions
#
function gitpush () {
    if [ -z "$1" ] ; then
        echo "Please supply message argument"
    else
        git add -u :/
        git commit -m "$1"
        GIT_EDITOR='true git commit' git pull
        git push
    fi
}

function modulelist () {
    local compiler=$( module -t list ${TACC_FAMILY_COMPILER} 2>&1 );
    local mpi=$( module -t list ${TACC_FAMILY_MPI} 2>&1 );
    local modules=$( module -t list 2>&1 | grep -v $compiler | grep -v $mpi | sort );
    for m in $compiler $mpi cont $modules;
    do
        if [ $m = "cont" ]; then
            echo "----------------";
        else
            loc=$(module -t show $m 2>&1 \
		      | sed -e 's?'${WORK}'?\$\{WORK\}?' \
		      | sed -e 's?'${SCRATCH}'?\$\{SCRATCH\}?' \
	       );
            echo "$m : $loc";
        fi;
    done
}

function modulereset () {
    module purge;
    module reset;
    if [ $( echo $MODULEPATH | grep eijkhout | wc -l ) -gt 0 ]; then
        echo "ERROR still private modules left:";
        echo ${MODULEPATH} | tr ':' '\n';
        exit 1;
    fi
}

function moduleload () {
    for m in $* ; do
	module -t load $m 2>/dev/null
	if [ $? -ne 0 ] ; then
	    echo && echo "ERROR: could not load module $m" && echo
	fi
    done
    modulelist
}

function modulerebuild ()
{
    uses="$( module -t describe $1 2>&1 | grep module )"
    mods="$( module -t describe $1 2>&1 | grep -v module )"

    nuse=$( echo "$uses" | wc -l )
    echo $nuse
    for iuse in $( seq $nuse )
    do
        line=$( echo $uses | awk -v u=$iuse 'NR==u {print}' )
        eval $line
    done

    nmod=$( echo "$mods" | wc -l )
    echo $nmod
    for imod in $( seq $nmod )
    do
        line=$( echo $mods | awk -v m=${imod} 'NR==m {print}' )
        eval module -t load $line
    done
}

