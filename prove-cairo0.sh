#!/usr/bin/env bash

set -e
cd "$(dirname "$0")"
source .env

rm -rf src result
cp -R src-cairo0 src
mkdir result

echo "Running circuit..."
cairo-compile src/circuit.cairo --output result/compiled.json --proof_mode
cairo-run \
    --program=result/compiled.json \
    --layout=recursive \
    --program_input=src/fibonacci_input.json \
    --air_public_input=result/public_input.json \
    --air_private_input=result/private_input.json \
    --trace_file=result/trace.json \
    --memory_file=result/memory.json \
    --proof_mode \
    --print_output

# absolute paths to relative
sed -E -i '' 's|"/[^"]*/result/|"./result/|g' result/private_input.json

ssh -i $key $dest "rm -rf src result"
scp -i $key -rp src result $dest:.

echo "Proving..."
ssh -i $key $dest ./cpu_air_prover \
    --generate_annotations \
    --out_file=./result/proof.json \
    --private_input_file=./result/private_input.json \
    --public_input_file=./result/public_input.json \
    --prover_config_file=./src/cpu_air_prover_config.json \
    --parameter_file=./src/cpu_air_params.json

echo "Sanity check verification..."
ssh -i $key $dest ./cpu_air_verifier --in_file=./result/proof.json 

scp -i $key -rp $dest:./result/proof.json ./result

echo "Successfully proved to ./result/proof.json"
