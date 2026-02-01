const snarkjs = require('snarkjs');
const { performance } = require('perf_hooks');

async function measure() {
    const input = {"secret": 1};

    console.time('Proof generation');
    const start = performance.now();
    const { proof, publicSignals } = await snarkjs.groth16.fullProve(input, 'circuit_js/circuit.wasm', 'circuit_0000.zkey');
    const end = performance.now();
    console.timeEnd('Proof generation');

    console.log('Time in ms:', end - start);
    console.log('Public signals:', publicSignals);
}

measure();
