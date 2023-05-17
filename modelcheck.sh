#!/usr/bin/env bash

input_model=${input_model:-$1}

source ~/repos/chain-replication/source.sh
tlc $input_model
