## Plonk circuit

# Compile circuit.circom circuit 
circom ./circuits/circuit.circom --sym --wasm --r1cs -o ./build/plonk

# Generate verification key based on Hermez 'Powers of Tau' MPC Ceremony
snarkjs plonk setup ./build/plonk/circuit.r1cs ./build/plonk/powersOfTau28_hez_final_16.ptau ./build/plonk/circuit_final.zkey
snarkjs zkey export verificationkey ./build/plonk/circuit_final.zkey ./build/plonk/verification_key.json

# Generate 'MerkVerifier.sol' solidity verification smart contract
snarkjs zkey export solidityverifier ./build/plonk/circuit_final.zkey ./contracts/plonk_verifier.sol