const { faker } = require('@faker-js/faker');
const fs = require('fs');
const path = require('path');

// Number of transactions per batch
const BATCH_SIZE = 100;
// Total batches
const NUM_BATCHES = 10; // Total 1000 tx

const txTypes = ['swap', 'borrow', 'transfer'];
const tokens = ['ETH', 'USDC', 'WBTC', 'DAI'];

const avatarStyles = ['identicon', 'lorelei', 'avataaars', 'bottts'];

const crypto = require('crypto');

function randomUint256() {
  return BigInt('0x' + crypto.randomBytes(32).toString('hex')).toString();
}

function generateTransaction(id) {
  const style = faker.helpers.arrayElement(avatarStyles);
  const seed = faker.string.uuid();
  const avatar_url = `https://api.dicebear.com/7.x/${style}/svg?seed=${seed}`;

  const a = [randomUint256(), randomUint256()];
  const b = [[randomUint256(), randomUint256()], [randomUint256(), randomUint256()]];
  const c = [randomUint256(), randomUint256()];
  const input = [randomUint256()];

  return {
    id,
    user_wallet: faker.finance.ethereumAddress(),
    avatar_url,
    tx_type: faker.helpers.arrayElement(txTypes),
    amount: parseFloat(faker.finance.amount(0.01, 1000, 6)),
    token: faker.helpers.arrayElement(tokens),
    timestamp: faker.date.recent({ days: 30 }).toISOString(),
    proof: { a, b, c, input },
  };
}

function generateBatch(batchId) {
  const transactions = [];
  const startId = (batchId - 1) * BATCH_SIZE;
  for (let i = 0; i < BATCH_SIZE; i++) {
    transactions.push(generateTransaction(startId + i));
  }
  return transactions;
}

async function generateData() {
  const syntheticDataDir = path.join(__dirname, 'synthetic_data');

  for (let batchId = 1; batchId <= NUM_BATCHES; batchId++) {
    const batchData = generateBatch(batchId);
    const fileName = `batch_${batchId}.json`;
    const filePath = path.join(syntheticDataDir, fileName);

    fs.writeFileSync(filePath, JSON.stringify(batchData, null, 2));
    console.log(`Generated ${fileName}`);
  }
}

generateData().catch(console.error);
