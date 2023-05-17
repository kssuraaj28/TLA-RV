#!/usr/bin/env bash

set -e

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$script_dir"



rfnment_vars=$(../get_rfnment_vars.sh critical_section.tla)

cd build 
make

rm -rf traces*/
mkdir traces_mutex/
mkdir traces_nolock/

for i in {1..10} ; do
    ./nolock
    mv logger_trace.txt traces_nolock/trace_$i
done

for i in {1..10} ; do
    ./mutex
    mv logger_trace.txt traces_mutex/trace_$i
done

echo "Creating trace collection model"

../../traces_to_spec.py critical_section nolock_model "$rfnment_vars" traces_nolock/*
../../traces_to_spec.py critical_section mutex_model "$rfnment_vars" traces_mutex/*

cp ../critical_section.tla .

../../modelcheck.sh nolock_model
#../../modelcheck.sh mutex_model
