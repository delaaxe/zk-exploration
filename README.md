# zk-exploration

## Setup

### Setup runner

```bash
git clone https://github.com/lambdaclass/cairo-vm.git
cd cairo-vm/cairo1-run
git checkout aecbb3f01dacb6d3f90256c808466c2c37606252
make deps
cargo build --release
cd ../..
ln -s cairo-vm/cairo1-run/corelib corelib
```

### Setup prover

Launch EC2 Ubuntu amd64 t2.medium 8gb SSD instance and edit variables in `.env`.

```bash
cp .env.example .env
source .env
scp -i $key ./cpu_air_{prover,verifier} $dest:.
ssh -i $key $dest "ls -lh"
```

Should output:
```
total 39M
-rwxr-xr-x 1 ubuntu ubuntu 20M May 31 10:18 cpu_air_prover
-rwxr-xr-x 1 ubuntu ubuntu 19M May 31 10:18 cpu_air_verifier
```

### Setup verifier

```bash
git clone https://github.com/HerodotusDev/integrity.git
cd integrity
# python configure.py -l small -s blake2s
scarb build
cargo build --release
cd ..
```

## Prove and verify

```bash
./prove.sh
./verify.sh
```
