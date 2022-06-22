## Plonk circuit

## Navigate to build/plonk 
cd ./build/plonk

# Compile circuit.circom circuit 
circom ../../circuits/circuit.circom --sym --wasm --r1cs
snarkjs r1cs info circuit.r1cs

## Generate the witness
node circuit_js/generate_witness.js circuit_js/circuit.wasm input.json witness.wtns

## Generate verification key based on Hermez 'Powers of Tau' MPC Ceremony
snarkjs plonk setup circuit.r1cs powersOfTau28_hez_final_16.ptau circuit_final.zkey
snarkjs zkey export verificationkey circuit_final.zkey verification_key.json

## Generate proof
snarkjs plonk prove circuit_final.zkey witness.wtns proof.json public.json

## Verify proof 
snarkjs plonk verify verification_key.json public.json proof.json

# ## Build verifier.sol verification contract to verify proof inside solidity smart contract as well!
echo 'Generating groth16_verifier.sol'
snarkjs zkey export solidityverifier circuit_final.zkey ../../contracts/plonk_verifier.sol