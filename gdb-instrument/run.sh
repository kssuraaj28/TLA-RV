#!/usr/bin/env bash
set -e

tla_file=${tla_file:-$1}
output_trace=${output_trace:-$2}
executable=${executable:-$3}

tla_file=$(realpath $tla_file)
output_trace=$(realpath $output_trace)
executable=$(realpath $executable)

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$script_dir"

shift 3

rfnment_vars=$(awk -F '--' '/state/ {print $NF ;exit}' $tla_file)

gdb --command=gdb-instrumentation --args $executable "$@" | grep ~~ | sed s/~//g  > "$output_trace"

echo $rfnment_vars
