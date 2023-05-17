#!/usr/bin/env bash
set -e
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$script_dir"

RANDOM=$(date +%s)

gcc GCD.c -o GCD -g


rfnment_vars=$(awk -F '--' '/state/ {print $NF ;exit}' GCD.tla)

rm -rf traces
mkdir traces


for i in {1..10} ; do
    x=$(($RANDOM+1))
    y=$(($RANDOM%x+1))
    x=$((x+1))
    gdb --command=gdb-instrumentation --args GCD $x $y | grep ~~ | sed s/~//g  > traces/trace_$i
    echo "Collected trace $i"
done

rm -rf Harness.tla
ln -s ../Harness.tla  .

echo "Creating trace collection model"
../traces_to_spec.py GCD tracemodel "$rfnment_vars" traces/*

source ~/repos/chain-replication/source.sh
tlc tracemodel
