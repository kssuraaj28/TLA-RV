#!/usr/bin/env bash
set -e
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$script_dir"

RANDOM=$(date +%s)

gcc GCD.c -o GCD -g


rm -rf traces
mkdir traces

rfnment_vars=$(../get_rfnment_vars.sh GCD.tla)
instr_cmd=../gdb-instrument/run.sh

for i in {1..10} ; do
    x=$(($RANDOM+1))
    y=$(($RANDOM%x+1))
    x=$((x+1))
    $instr_cmd GCD.tla "traces/trace_$i" GCD $x $y
    echo "Collected trace $i"
done

echo "Creating trace collection model"
../traces_to_spec.py GCD tracemodel "$rfnment_vars" traces/*

../modelcheck.sh tracemodel
