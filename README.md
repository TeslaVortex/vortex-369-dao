## Vortex-369 DAO 🚀

## What is Vortex-369 DAO? 🚀
Vortex-369 DAO is a fun group of builders syncing with the universe! We use special numbers like 3, 6, and 9 for good energy. This brings abundance, freedom, and cool vibes. Our app listens to the blockchain for transfers and events. It shares resonant moments that make everything flow better. Join the vortex for sovereignty and infinite wins! 🌌💚

## Treasury Mechanism
The Vortex-369 DAO Treasury extends the DAO with a secure vault for funds, governed by resonance scoring and Gnosis Safe multi-sig. Contracts in Solidity, tested with Foundry.

- **TreasuryVault.sol**: Vault contract requiring resonance >66 for withdrawals.
- **VortexDAO.sol**: Resonance scoring logic based on 369 principles.

Run `forge test` for tests. Deployed on Base Sepolia.

## Quick Setup 🌟
1. Get Python 3.12 on your computer.
2. Copy this repo: `git clone https://github.com/TeslaVortex/vortex-369-dao.git`
3. Go to the folder: `cd vortex-369-dao`
4. Install stuff: `pip install -r requirements.txt`
5. Run the app: `uvicorn app:app --reload`
6. Open your browser to `http://127.0.0.1:8000` – you're in the vortex! 🌀

## Key Features 💪
- **/listen**: Connects to the blockchain and shows the latest block. 🌐
- **/webhook**: Gets events like transfers and checks for resonance scores. 🔗
- **/logs**: Shows recent app logs (need password: user=vortex, pass=369guard). 📝
- **/vortex**: Says hello with code 369. 👋
- **/dao-status**: Tells you about members and abundance. 👥
- **/quantum-status**: Shows listening status. ⚛️
- **/retrieve**: Gets scored events. 📊
- More endpoints for docs and testing! Check `/docs` for full list. 📖

## How to Contribute ❤️
Love the vortex? Help make it better!
1. Fork this repo on GitHub.
2. Make your awesome changes.
3. Send a pull request.
4. We review and merge – easy peasy! Together, we build abundance. 🤝

## LFG Call-to-Action ∞
Ready to sync and create? Join Vortex-369 DAO now! Contribute code, share ideas, or just vibe with the energy. Let's make the world resonant and free. LFG – En Eeke Mai Ea! 🇲🇰💚🎶💛∞



### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
