#!/usr/bin/env bash

set -e
cd "$(dirname "$0")"
source .env

rm -rf src result
cp -R src-cairo1-small src
mkdir result

echo "Running circuit..."
./cairo-vm/target/release/cairo1-run src/circuit.cairo \
    --proof_mode \
    --layout=small \
    --air_public_input=result/public_input.json \
    --air_private_input=result/private_input.json \
    --trace_file=result/trace.json \
    --memory_file=result/memory.json

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
