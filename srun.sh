# -*- sh -*-
#!/bin/bash

function usage () {
    echo "Usage: $0 [ options ] -- commandline"
    echo "    [ -h ] [ -A project ] [ -p partition (default: $partition) ] [ -t hh:mm:ss ]"
    echo "    [ -N 12 (nodes) ] [ -n 1234 (cores) ]"
    echo "    [ -d dir (execute in directory) ] [ -g : gdb ] [ -s : single spawn ]"
}

# defaults for srun options
project=A-ccsc
case  "${TACC_SYSTEM}" in
    ( ls6 ) partition=development ;;
    ( * ) partition=small ;;
esac
time=0:10:0
nodes=1
cores=1
# my own options
dir="."
gdb=
single=

while [ $# -gt 0 ] ; do
    if [ $1 = "-h" ] ; then
	usage && exit 0
    elif [ $1 = "-N" ] ; then
	shift && nodes=$1 && shift
    elif [ $1 = "-n" ] ; then
	shift && cores=$1 && shift
    elif [ $1 = "-p" ] ; then
	shift && partition=$1 && shift
    elif [ $1 = "-t" ] ; then
	shift && time=$1 && shift
    elif [ $1 = "-d" ] ; then
	shift && dir="$1" && shift
    elif [ $1 = "-g" ] ; then
	shift && gdb="gdb"
    elif [ $1 = "-i" ] ; then
	shift && interactive="--pty /bin/bash"
    elif [ $1 = "-s" ] ; then
	shift && single=1
    elif [ $1 = "--" ] ; then
	shift && break
    else
	echo "Error: unknown option <<$1>>" && exit 1
    fi
done
if [ $# -eq 0 ] ; then
    echo "Error: no executable given"
    usage && exit 1
fi

cd "$dir"
##
## Instead of directly running the commandline
## we create a script containing such
## In "single" mode we let only SLURM_PROCID zero
## execute the script
##
export commands="$*"
script=".srun_script.sh"
if [ -z "${single}" ] ; then
    # execute as such
    cat <<EOF >${script}
#!/bin/bash
$commands
EOF
else
    # execute only on proc zero
    cat <<EOF >${script}
#!/bin/bash
if [ -z "\${SLURM_PROCID}" ] ; then
  echo "ERROR slurm procid undefined" ; exit 1 ; fi
if [ \${SLURM_PROCID} -gt 0 ] ; then exit 0 ; fi
$commands
EOF
fi

# echo "Script:"
# cat ${script}
# echo " << script:"
chmod +x ${script}

srun \
    --export=ALL \
    -A $project -p $partition -t $time -N $nodes -n $cores \
    $interactive $gdb ./${script}
    
