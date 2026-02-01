const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const CONTRACT_ADDRESS = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
const RPC_URL = 'http://localhost:8545'; // Assume anvil running
const FUNCTION_SIG = 'verifySecret(uint256[2],uint256[2][2],uint256[2],uint256[1])';

const syntheticDataDir = path.join(__dirname, 'synthetic_data');

function getBatches() {
  return fs.readdirSync(syntheticDataDir).filter(f => f.endsWith('.json')).sort();
}

function runBenchmark() {
  const batches = getBatches();
  let totalGas = 0n;
  let totalTx = 0;
  const startTime = Date.now();

  for (const batchFile of batches) {
    const batchPath = path.join(syntheticDataDir, batchFile);
    const transactions = JSON.parse(fs.readFileSync(batchPath, 'utf8'));

    for (const tx of transactions) {
      const { a, b, c, input } = tx.proof;
      const args = `${a[0]} ${a[1]} ${b[0][0]} ${b[0][1]} ${b[1][0]} ${b[1][1]} ${c[0]} ${c[1]} ${input[0]}`;
      try {
        const output = execSync(`cast estimate --rpc-url ${RPC_URL} ${CONTRACT_ADDRESS} "${FUNCTION_SIG}" ${args}`, { encoding: 'utf8' });
        const gas = BigInt(output.trim());
        totalGas += gas;
        totalTx++;
        console.log(`Tx ${tx.id}: Gas ${gas}`);
      } catch (error) {
        console.error(`Error estimating gas for tx ${tx.id}: ${error.message}`);
      }
    }
  }

  const endTime = Date.now();
  const totalTime = endTime - startTime;
  const avgGas = totalTx > 0 ? totalGas / BigInt(totalTx) : 0n;

  console.log(`\nBenchmark Results:`);
  console.log(`Total Transactions: ${totalTx}`);
  console.log(`Total Gas: ${totalGas}`);
  console.log(`Average Gas per Tx: ${avgGas}`);
  console.log(`Total Time: ${totalTime} ms`);
  console.log(`Avg Time per Tx: ${totalTx > 0 ? totalTime / totalTx : 0} ms`);

  // Comparisons (estimates based on research)
  console.log(`\nCompetitor Comparisons (gas per tx):`);
  console.log(`Pellion Shield (simulated): ${avgGas}`);
  console.log(`Aztec: ~200,000 gas`);
  console.log(`Railgun: ~150,000 gas`);
  console.log(`Tornado Cash: ~180,000 gas`);
  console.log(`Note: Mock proofs used; real ZK verification gas may vary.`);
}

runBenchmark();
