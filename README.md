# PLONK Tutorial
README referenced and modified from https://github.com/enricobottazzi/ZKverse. Special thanks to Enrico from Polygon ID!

# **Introduction to Zero Knowledge Proofs**

To understand zero knowledge proof, it is first necessary to define the 2 actors involved in the process and their roles:

1. A Prover, who executes a computation and wants to prove to any third party that the computation was valid.
2. A Verifier, whose role is to verify that the computation done by someone else was valid.

A computation is any deterministic program that gets input(s) and returns output(s). The naive way for a verifier to verify that a computation done by a third party was valid would be to run the same program with the same input(s) and check if the output is the same.

But what if the program took one day to compute for the prover? Then the verifier (and anybody who wants to verify its correctness) has to spend one day to verify if the computation was performed correctly. This process is highly inefficient. 

How do _Zero Knowledge Proofs_ work?

- It all starts with having a deterministic program (*circuit*).
- The prover executes the computation and computes the output of the program.
- The prover, starting from the circuit and the output, computes a **proof** of his/her computation and gives it to the verifier.
- The verifier can now run a more lightweight computation starting from the proof and verify that the prover did the entire computation correctly. **The verifier doesn’t need to know the whole set of inputs to verify the correctness of the computation**.

Starting from this definition, we can define the two main application areas of ZKP:
- scalability, which benefits from the lower effort needed for the verifier to verify the correctness of the computation.
- privacy, which benefits from the fact that the verifier can verify the correctness of the output provided without having to know the entire set of inputs needed to get there.

<img width="631" alt="screenshot1" src="https://user-images.githubusercontent.com/70081547/175160633-e89028ea-203e-4fdf-a908-6413f1c4b437.png">

In cryptography, a zero-knowledge proof is a method by which one party (the prover) can prove to another party (the verifier) that he/she knows a value x that fulfills some constraints, without revealing any information apart from the fact that he/she knows the value x.

## **ZKP as scalability-enabling technology**

For example, right now, miners need to validate every single transaction and add it to a new block and other nodes, to approve it and reach consensus will need to check the validity of the transactions by processing each one of them.

With ZKP they don't need to! A prover can validate every single transaction, bundle them all together and generate a proof of their computation. Any other party (verifiers) can get the **public** inputs of the computation, the **public** output, and the proof generated by the prover and verify the validity of the computation in just a few milliseconds. They don't need to compute all the transactions again. They just need to compute the proof.

That's how ZKP can enable scalability in blockchain technology. 

We can define: 

Zero-knowledge proof is a method by which one party (the prover) can prove to another party (the verifier) in an easily verifiable way that he/she was able to execute a computation within some constraints starting from a public set of inputs.

**This is the magic of scalability enabled by zkp**

## **ZKP as privacy-enabling technology**

The prover can execute a hash function (non-reversible function) and provide the result of the function + the proof. From these two pieces, the verifier can verify that the prover ran the function correctly without knowing the inputs of the function. 

Note that in this case, the function inputs are **private** so the prover doesn't have to reveal any detail about the data used to generate the hash function. Here's where the zero-knowledge/privacy component comes into place. 

The scalability and privacy applications are enabled by the **succinct nature of the proof**, namely the proof doesn't contain anything about the origin of the information and is really small.

We can define: 

Zero-knowledge proof is a method by which one party (the prover) can prove to another party (the verifier) that the prover knows a value x that fulfills some constraints without revealing any information apart from the fact that he/she knows the value x.

**This is the magic of privacy enabled by ZKP!**

# Tutorial Structure

```Build```

Groth16 and plonk binary files, prover/verification keys, and Hermez Power's of Tau Ceremony

```Circuits```

Circom circuits 

```Contracts```

Solidity verification smart contracts 

```Scripts```

Runs groth16 and plonk prover and deploys smart contracts

```Test```

Runs unit tests using etherJS and hardhat

# Tools and Resources

- Circom 2 (ZK-SNARK Compiler)<br />
- SnarkyJS (Typescript/Javascript Framework for zk-SNARKs)<br />
- Solidity (Smart Contract Programming Language)
- Ether.js / Hardhat / Ganache<br />

# **Circom and SnarkJS Demo**

### Execute scripts

The demo illustrates a **range proof**: proving a number is within a range without revealing the actual number. This could be useful in applications that require, for example, proving your income is in a specified range when applying for a credit card without revealing your specific income. 

The scripts contain all the information neccessary to generate groth16 and plonk proofs for circom circuits. 

1. Install dependecies with `npm install` in the root directory.
2. Run the groth16 and plonk scripts with `sh scripts/compile_groth16.sh` and `sh scripts/compile_plonk.sh`.
3. Run `npx hardhat test` to run the unit tests.

### Manually run commands

If you prefer to run the commands **manually**, the plonk setup is explained in-depth and the commands are described below.

Each step of the demo, the data, the actors, and their actions are better explained in this board:
<img width="755" alt="Screen Shot 2022-06-22 at 3 11 04 PM" src="https://user-images.githubusercontent.com/70081547/175161365-279d2948-623c-485a-9d79-99506b583390.png">

Here's the link to the Miro board: https://miro.com/app/board/uXjVODmIOnk=/?invite_link_id=155047731605

## 1. Dependencies Setup

### Install rust

`curl --proto '=https' --tlsv1.2 [https://sh.rustup.rs](https://sh.rustup.rs/) -sSf | sh`

### Build circom from source

`git clone [https://github.com/iden3/circom.git](https://github.com/iden3/circom.git)`

`cd circom`

`cargo build --release`

`cargo install --path circom`

### Install snarkjs

`npm install -g snarkjs`

## 2. Create the circom circuit
 
```
pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/comparators.circom";

// Range proof circuit 
template RangeProof(n) {
    // Max field size is 252 bits
    assert(n <= 252);

    // Private and public inputs; Check whether input is within range[lowerBound,upperBound]
    signal input in;            
    signal input lowerBound;    
    signal input upperBound;    
    signal output out;

    // Instantiate templates as components
    component low = LessEqThan(n);
    component high = GreaterEqThan(n);

    // Check whether the input is greater than or equal to the lower bound
    high.in[0] <== in;
    high.in[1] <== lowerBound;
    high.out === 1;

    // Check whether the input is less than or equal to the upper bound
    low.in[0] <== in;
    low.in[1] <== upperBound;
    low.out === 1;

    out <== high.out * low.out;
 }

component main = RangeProof(32);
```

This circuit describes a basic computation: checking whether an input is in the range of two other inputs.

A circuit is a deterministic program containing the constraints that must be respected to successfully run the computation successfully. The goal for the prover is to prove to a verifier that he/she knows an input 'in' that that is within the range of some lower and upper bounds.

The inputs are kept private. The verifier doesn't have access to it. 
The output is public. The verifier has access to it.

### Compile the circuit

Naviagate to the `build` directory, and run all of the following commands: 

`circom ../../circuits/circuit.circom --sym --wasm --r1cs`

It's important to notice that by running this command, it compiles the circuit and generates two types of files in the process:

--r1cs it generates the file circuit.r1cs that contains the constraints of the circuit in binary format.

--wasm: it generates the directory circuit that contains the Wasm code (circuit.wasm) and other files needed to generate the witness.

### Print info on the circuit

`snarkjs r1cs info circuit.r1cs`

```jsx
[INFO]  snarkJS: Curve: bn-128
[INFO]  snarkJS: # of Wires: 67
[INFO]  snarkJS: # of Constraints: 65
[INFO]  snarkJS: # of Private Inputs: 3
[INFO]  snarkJS: # of Public Inputs: 0
[INFO]  snarkJS: # of Labels: 85
[INFO]  snarkJS: # of Outputs: 1
```

## 3. Generate the witness 

### Generate the witness

The witness is the set of inputs, intermediate circuit signals and output generated by prover's computation. 

For the sake of this example, the prover is choosing 2,1,3. The inputs are added in a .json file called *input.json*.

To generate the witness `node circuit_js/generate_witness.js circuit_js/circuit.wasm input.json witness.wtns`.

It is passing in 3 parameters:
- `circuit_js/circuit.wasm` is the previously generated file needed to generate the witness.
-`input.json` is the file that describes the input of the computation.
- `witness.wtns` is the output file. Witness.wtns will display all the intermediary values that the program is computing.

### Display the witness 

Right now the file `witness.wtns` is in binary so it needs to be converted to .json to actually read that.

`snarkjs wtns export json witness.wtns witness.json`

The file describes the wires computed by the circuit. In simple terms, the intermediary steps computed by the circuit to get from the inputs to the output.

## 4. Generate the proof 

### Download the trusted setup (Powers of tau file) 

`wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_16.ptau`

It is a community-generated trusted setup. A trusted setup is an algorithm that determines a protocol’s public parameters using information that must remain secret to ensure the protocol’s security.

### Generate the verification key

The verification key is generated starting from `circuit.r1cs` (description of the circuit and its constraints) and `powersOfTau28_hez_final_16.ptau` which is the trusted setup. The output file of the operation is `circuit.zkey`, namely the verification key for the circuit.

`snarkjs plonk setup circuit.r1cs powersOfTau28_hez_final_16.ptau circuit_final.zkey`

### Get a verification key in json format (from the proving key)

`snarkjs zkey export verificationkey circuit_final.zkey verification_key.json`

<img width="661" alt="Screen Shot 2022-06-22 at 3 36 18 PM" src="https://user-images.githubusercontent.com/70081547/175165654-352b0d68-2ab5-4f71-a257-178677f224cf.png">

### Generate the proof

Let's zoom back for a second. The prover holds:
- A witness (`witness.wtns`) that describes its computation starting from the public inputs (2, 1, 3), the intermediary values, and output.
- A verifcation key (`circuit.zkey`).

The goal now is to generate a proof starting from these files and provide it to the verifier. 

`snarkjs plonk prove circuit_final.zkey witness.wtns proof.json public.json`

The outputs are:
- The proof of the computation (`proof.json`)
- The public values are included in the computation (`public.json`). In this particular case the only public value visible by the verifier is the output of the computation.

Here's the plonk proof:

<img width="672" alt="Screen Shot 2022-06-22 at 3 36 38 PM" src="https://user-images.githubusercontent.com/70081547/175165681-691cbb10-dbcd-4bd0-a708-9555394c852a.png">

## 5. Verify the proof via snarkjs

Now the focus switches to the side of the verifier. The verifier only has access to the `public.json`, `proof.json` and `verification_key.json` files. 
It is important to underline that none of these files contains information about the inputs chosen by the prover to run the computation.
His/her goal is to prove that the computation performed by the prover was correct, namely that input was within the range of the lower and upper bound represented by the two other inputs **without knowing any information about the inputs chosen to run the computation.**

### Verify the proof

`snarkjs plonk verify verification_key.json public.json proof.json`

As you can see to do that I only need to have the verification key (`verification_key.json)`, the public output (`public.json`) and the computation proof `proof.json`. The result of the command tells that the result of the verification is positive! You can try to modify a single unit in the proof file and will see that the verification will fail. 

It's important to note that in this case snarkjs has been run in the command line but you can integrate it in any node program in the browser. 

## 6. Verify the proof via a solidity smart contract

### 6.1. Generate a solidity verifier smart contract

Snarkjs provides a tool that allows generating a solidity smart contract in order to validate this proof. It is generated starting from the circuit_final.zkey. The output of the program is the `verifier.sol` file.

`snarkjs zkey export solidityverifier circuit_final.zkey ../../contracts/plonk_verifier.sol`

Now you can run this contract on the Remix IDE (copy and paste it directly).

This contract has just one function that is *verifyProof* that takes the proof as input and outputs a bool (true or false) telling if the verification was successful or not.

<img width="629" alt="screenshot9" src="https://user-images.githubusercontent.com/70081547/175165978-34160560-bb0a-4e2a-9fc8-3ab6f8703795.png">

### 6.2. Generate solidty calldata

In this second scenario, the verifier is the smart contract itself. The verification is performed similarly as before, it only needs to export the `proof.json` and `public.json` files in bytes format in order to let verifier.sol understand it.

In order to generate the proof in bytes format, it needs to run:

`snarkjs zkey export soliditycalldata public.json proof.json`

Below is the result of the command:

`0x0802f0ddc3ee99c3cfae84fd00ca5e12f6e411b428c53a87bb336dbb796be650220ca6aa260477ccde55b31e25c020ef517d5f5478ab04f008f2657fac24e4d40ac0a6538e736d6d532dd2b6ccbee0055bf52edcf3dfd538867e69e336c2394421a53fd38e41afaa5118f978a7cc137197e00e5c47ee6842408e70cfe40e78581d7a4b57cd32751ea6e1c16da84a8e32f830ffb9d66c1957c6944f6479d4f2fb0ed38bec3967ed1edfd0e845915ddadefa6318a572657ab29660d62a94d7a5f1150987504205e59b2b1858d409d52c60cc47e016d6ec283a5acbd8deea8bf01d0ea60bd7b3339b0337f82fa0c5d6fb2ce8c6d2b81c48e42f03029dec884aab4c1b1411201035346c06f45653c8568534d118ae8c8f6055347e53221968b6914d25b3ad5cc53043b400e591684a2ad2372af1ffde775cbc4e0aa77001ccc9b969089f0330b91bdde58641f7c7fe6531a48dc8f90de401b66806bfb1b80d2fe11f21223b977d5f2616966a481c0dc36e8c5e3c6b1f909f6e415f00986c0b4d151c1e656bfc73ca1ddc15417b353d48b091dcd14e812a36b118e003344927234f5603e646becc5a4f5b3e0409c05ead865d60540b4adb02fe8b1734aff7b29dcb5811c5654f6f5c94a50f6871313e3339abf97663b2851c88e994ac6a0328e9733f28866b6bb1761b15f67f7e78cad75b1a0594e4ed5f6a57d842d3fb38539591672820380d8a3d473d0d4c48d505e487060578d6bbaada83497fec8683988df71017f001752b0c6f7af27001a0f9a0b72fb914ffa02895210710ede413e3bf23c32d6bc6047650b3fc8f94f24e4b13f1875a938ffd27ee0a70069129d2d67745500b7bcdad3aea46d719a81874c24cee2822ac9bd089a9fee0e6b83aa95e22936c2609de92568ebd44aaaa10067e644eb057959ee4a3aa9da62a8aea54e69e5f2a0ff7714d76dfc8815f300cc369221feec73181868cb4632347ab83ad121d563b0fa7960e29f8ac20231358ef25c3a69564ff897b3feaeb34eb15b756f1d225fd012c5107b1fc2e103ddb783078ecb5b6b8005bd48f1b3e0ef2faa8ceb87ef21819408d7cc26806a72d93dd67186076821b43d98e43897a42d2aaa87de5e79478,["0x0000000000000000000000000000000000000000000000000000000000000001"]`

The first part is the proof written in bytes, while the array, in this case, contains only one value (which is 33 written in hexadecimal)

To test it, input the proof and the hex array into the smart contract on Remix.

![screenshot11](https://user-images.githubusercontent.com/70081547/175166128-f9c5d008-3361-4c5d-abc6-b9fbb255770d.png)

As you can see, the proof has been verified!

## **Docs**

- [circom documentation](https://docs.circom.io/getting-started/installation/#installing-circom) 
- [circom github](https://github.com/iden3/circom)
- [circomlib](https://github.com/iden3/circomlib)
- [circomlibjs](https://github.com/iden3/circomlibjs)
- [snarkJS](https://github.com/iden3/snarkjs)
- [rapidSnark](https://github.com/iden3/rapidsnark)

## **Other Resources**
- [zkEVM with Jordi & David from Hermez](https://zeroknowledge.fm/episode-194-zkevm-with-jordi-david-from-hermez/)
- [SNARKS FOR NON-CRYPTOGRAPHERS - obront.eth Twitter post](https://twitter.com/zachobront/status/1501943116923740164?s=20&t=mNJuwAYe7fIPk5Lu5VNhxg)
- [Jordi Baylina : ZK-EVM](https://www.youtube.com/watch?v=17d5DG6L2nw&t=14s)
- [ZK Jargon Decoder - @nico_mnbl](https://nmohnblatt.github.io/zk-jargon-decoder/foreword.html)
- [Introduction to circom 2.0 - Albert Rubio & Josè M](https://youtu.be/6XxVeBFmIFs)


