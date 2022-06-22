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