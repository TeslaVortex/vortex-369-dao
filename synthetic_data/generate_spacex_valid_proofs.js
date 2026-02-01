const { faker } = require('@faker-js/faker');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const numTx = 100; // Comprehensive batch
const txTypes = ['rocket_launch_funding', 'satellite_deployment', 'mars_mission_donation', 'starship_ticket', 'starlink_payment', 'crew_dragon_mission', 'spacex_merch_purchase', 'falcon_heavy_boost'];
const tokens = ['ETH', 'BTC', 'DOGE', 'USDC'];

function randomUint256() {
  return BigInt('0x' + crypto.randomBytes(32).toString('hex')).toString();
}

function generateSpaceXTx(id) {
  const seed = faker.string.uuid();
  const avatar_url = `https://robohash.org/${seed}.png`;

  const a = [randomUint256(), randomUint256()];
  const b = [[randomUint256(), randomUint256()], [randomUint256(), randomUint256()]];
  const c = [randomUint256(), randomUint256()];
  const input = [randomUint256()]; // Mock public signal

  return {
    id,
    user_wallet: faker.finance.ethereumAddress(),
    avatar_url,
    tx_type: faker.helpers.arrayElement(txTypes),
    amount: parseFloat(faker.finance.amount(100, 10000, 2)),
    token: faker.helpers.arrayElement(tokens),
    timestamp: faker.date.recent({ days: 30 }).toISOString(),
    proof: { a, b, c, input },
  };
}

function generateSpaceXBatch() {
  const txs = [];
  for (let i = 0; i < numTx; i++) {
    txs.push(generateSpaceXTx(i));
  }

  const batchPath = path.join(__dirname, 'spacex_batch.json');
  fs.writeFileSync(batchPath, JSON.stringify(txs, null, 2));
  console.log(`Generated comprehensive SpaceX batch with ${numTx} tx to ${batchPath}`);
}

generateSpaceXBatch();
