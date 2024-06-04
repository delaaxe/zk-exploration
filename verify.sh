#!/usr/bin/env bash

set -e
cd "$(dirname "$0")"

export RUST_BACKTRACE=full

ln -s -f integrity-recursive-keccak integrity
./integrity/target/release/runner integrity/target/dev/cairo_verifier.sierra.json < result/proof.json

ln -s -f integrity-small-blake2s integrity
./integrity/target/release/runner integrity/target/dev/cairo_verifier.sierra.json < result/proof.json

# 155785504329508738615720351733824384887 = "u32_sub Overflow"

cd integrity
python configure.py -l small -s keccak

cargo run --bin runner -- target/dev/cairo_verifier.sierra.json < ../result/proof.json 