pragma circom 2.0.0;

// Circuit performs a simple multiplication of two signals

template Circuit () {  

    // Declaration of signals
   signal input a;  
   signal input b;
   signal input c;
   signal output d;  
   
   // Constraints  
   signal x <== a * b;
   d <== x * c;  
}

component main = Circuit();