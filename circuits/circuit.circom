pragma circom 2.0.0;

template Main() {
    signal input secret;
    signal output public_hash;

    public_hash <== secret * 2;
}

component main = Main();
