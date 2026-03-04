# -*- sh -*-
#!/bin/bash

function usage () {
    echo "Usage: $0 [ options ] -- commandline"
    echo "    [ -h ] [ -A project ] [ -p partition (default: $partition) ] [ -t hh:mm:ss ]"
    echo "    [ -N 12 (nodes) ] [ -n 1234 (cores) ]"
    echo "    [ -d dir (execute in directory) ] [ -g : gdb ]"
}

# defaults for srun options
project=A-ccsc
partition=small
time=0:10:0
nodes=1
cores=1
# my own options
dir="."
gdb=

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

script=sbatch_script
command=$*

set -x
cd "$dir"
cat > "$script" <<EOF
#!/bin/bash
#SBATCH -J sbatch
#SBATCH -o sbatch.o%j
#SBATCH -e sbatch.o%j
#SBATCH -A $project
#SBATCH -p $partition
#SBATCH -t $time
#SBATCH -N $nodes
#SBATCH -n $cores

$command
EOF

sbatch "$script"

# srun -A $project -p $partition -t $time -N $nodes -n $cores \
#     $interactive $gdb $*
    
