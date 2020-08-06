# contracts
Smart Contract for The Sentinel AI


## Testing Locally

1. Run a Local Chain via `ganache-cli --networkId 1001 -l 8000000`
2. Run `npm run migrate` to deploy the contract to the local chain.

## Production Deploy

1. Configure a MNEMONIC in `.env` file.
2. Run `npm run migrate-prod` to deploy the contract to the Matic Mumbai Testnet.
