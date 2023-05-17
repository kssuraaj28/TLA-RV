#!/usr/bin/env bash

input_tlafile=$1
rfnment_vars=$(awk -F '--' '/state/ {print $NF ;exit}' $input_tlafile)
echo $rfnment_vars

