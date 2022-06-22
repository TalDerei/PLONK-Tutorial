#!/bin/bash

## Groth16 Script

# Build withdraw.circom and merkleTree.circom circuits
TARGET_CIRCUIT=../../circuits/circuit.circom
PTAU_FILE=./pot12_final.ptau
ENTROPY_FOR_ZKEY=random_text
cd ./build/groth16

## Generate circuit.r1cs & circuit.sym & circuit.wasm
echo 'Generating circuit.r1cs & circuit.sym & circuit.wasm'
circom $TARGET_CIRCUIT --r1cs --wasm --sym
snarkjs r1cs info circuit.r1cs

# ## Start Powers of Tau ceremony (Trusted Ceremony)
snarkjs powersoftau new bn128 10 pot12_0000.ptau -v

## Contribute to ceremony by adding entropy
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v

## Generate circuit_0000.zkey
echo "Generating circuit_0000.zkey"
snarkjs zkey new circuit.r1cs $PTAU_FILE circuit_0000.zkey

## Generate circuit_final.zkey
echo "Generating circuit_final.zkey"
echo $ENTROPY_FOR_ZKEY | snarkjs zkey contribute circuit_0000.zkey circuit_final.zkey

## Generate verification_key.json
echo "Generating verification_key.json"
snarkjs zkey export verificationkey circuit_final.zkey verification_key.json

## Build verifier.sol
echo 'Generating groth16_verifier.sol'
cd ../../contracts/

snarkjs zkey export solidityverifier ../build/groth16/circuit_final.zkey groth16_verifier.sol