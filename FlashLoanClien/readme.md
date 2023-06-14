## Smart Contract Communication Code

This code is designed to facilitate communication with a smart contract using ethers.js. It provides functions for interacting with the deployed smart contract using the specified RPC provider and contract address.

## Getting Started

To use this code, please follow the steps below:

1. Create a `.env` file in the root directory of your project.
2. Set the following variables in the `.env` file:

   - `rpcLink`: RPC provider link (for mainnet, you can use an Infura link).
   - `mnemonic`: BIP39 mnemonic to retrieve the address and private key. You can generate it using [this BIP39 generator](https://it-tools.tech/bip39-generator).
   - `accountIndex`: Account index in the mnemonic. The default is 0, which represents the first account.
   - `contractAddress`: Deployed smart contract address.

   Example `.env` file:

   ```
   rpcLink=https://mainnet.infura.io/v3/your-infura-project-id
   mnemonic=your-bip39-mnemonic
   accountIndex=0
   contractAddress=0x123456789abcdef123456789abcdef1234567890
   ```

3. Install the required dependencies by running `npm install` or `yarn install`.

## Usage

In your TypeScript file, import the necessary ethers.js components and the `FlashLoanContract` class from the `provider.ts` file:

```typescript
import { ethers } from "ethers";
import { FlashLoanContract } from "./provider";
```

Create an instance of the `FlashLoanContract` class:

```typescript
const provider = new ethers.providers.JsonRpcProvider(process.env.rpcLink);
const signer = ethers.Wallet.fromMnemonic(process.env.mnemonic).connect(
  provider
);
const smartContract = FlashLoanContract.create(
  signer,
  process.env.contractAddress
);
```

### Simple Flash Loan

To execute a simple flash loan, use the following code:

```typescript
const txHash = await smartContract.initSimpleFlashLoan(...args);
```

Replace `...args` with the necessary arguments for the flash loan function.

### Triangle Flash Loan

To execute a triangle flash loan, use the following code:

```typescript
const txHash = await smartContract.initTriangleFlashLoan(...args);
```

Replace `...args` with the necessary arguments for the flash loan function.

### Transaction Hash

After successfully executing the flash loan transaction, the function will return the transaction hash (`txHash`).

## Type Safety

The `contractsMetadata` include the smart contract types, which make the code type-safe and provide better development experience.

---
