# SimpleFlashLoan

This Solidity smart contract provides a simple implementation of flash loans using the Aave protocol and Uniswap decentralized exchanges.

## Overview

The SimpleFlashLoan contract allows the owner to execute flash loans with different swapping strategies. It supports two types of flash loans:

- Simple Flash Loan: Executes a flash loan with two DEXes (decentralized exchanges). The borrowed token is swapped from the buying DEX to ETH using Uniswap.

- Triangular Flash Loan: Executes a flash loan with three DEXes, performing an additional intermediate swap. The borrowed token is swapped from the buying DEX to ETH via the intermediate DEX using Uniswap.

## Detailed Description

The contract SimpleFlashLoan inherits from two other contracts: FlashLoanSimpleReceiverBase and Ownable. FlashLoanSimpleReceiverBase is a base contract provided by Aave for receiving and executing flash loans, while Ownable is a contract from the OpenZeppelin library that provides basic ownership functionality.

The constructor of SimpleFlashLoan takes an `_addressProvider` parameter, which is the address of the Aave Pool Addresses Provider. It initializes the FlashLoanSimpleReceiverBase contract by passing the address provider to it.

The contract provides two main functions for executing flash loans: `executeSimpleFlashLoan` and `executeTriangularFlashLoan`. Both functions can only be called by the contract owner (onlyOwner modifier).

The `executeSimpleFlashLoan` function is used for performing a flash loan with two DEXes. It takes the addresses of the buying and selling DEXes (`dexAddresses`), the swap path of the buying DEX (`buyingPath`), the swap path of the selling DEX (`sellingPath`), and the amount of the flash loan (`amount`) as parameters. It validates that `dexAddresses` has a length of 2 and the borrowed asset is the first element of `buyingPath`. It then encodes the parameters and calls the internal `requestFlashLoan` function to initiate the flash loan.

The `executeTriangularFlashLoan` function is similar to `executeSimpleFlashLoan`, but it allows for a triple swap. It takes an additional `intermediatePath` parameter, representing the swap path of an intermediate DEX. It validates that `dexAddresses` has a length of 3 and the borrowed asset is the last element of `buyingPath`. It encodes the parameters and calls `requestFlashLoan`.

The `requestFlashLoan` function is a private helper function used to initiate the flash loan. It takes the token to borrow (`_token`), the loan amount (`_amount`), and the encoded parameters (`params`). It retrieves the address of the contract itself as the `receiverAddress` and sets it as the asset to be borrowed. It then calls the `flashLoanSimple` function inherited from FlashLoanSimpleReceiverBase to request the flash loan.

The `executeOperation` function is a required implementation of the FlashLoanReceiverBase interface. It is called by Aave to execute the flash loan operation. It receives the borrowed asset, the amount, the premium (fee), the initiator of the flash loan, and the encoded parameters (`encodeParams`). The function decodes the parameters and calls either `doubleSwap` or `tripleSwap` depending on the length of `dexAddresses`.

The `doubleSwap` and `tripleSwap` functions are private functions used for performing the actual swapping operations. They interact with the Uniswap V2 Router contracts (IUniswapV2Router02) to swap tokens. `doubleSwap` swaps tokens from the buying DEX to ETH, while `tripleSwap` performs an additional intermediate swap before swapping to ETH.

The `executeOperation` function completes by approving the borrowed asset to be withdrawn by the Aave pool and transferring any remaining tokens back to the initiator.

## Prerequisites

- Solidity ^0.8.10
- Aave core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol
- OpenZeppelin contracts/access/Ownable.sol
- OpenZeppelin contracts/token/ERC20/IERC20.sol
- UniswapV2Periphery contracts/interfaces/IUniswapV2Router02.sol

## Usage

To use the SimpleFlashLoan contract, follow these steps:

1. Deploy the SimpleFlashLoan contract by providing the address of the Aave Pool Addresses Provider to the constructor.

2. Call the `executeSimpleFlashLoan` function to perform a simple flash loan. Only the contract owner can execute this function. Provide the following parameters:

   - `dexAddresses`: An array of two addresses representing the buying and selling decentralized exchanges (DEXes).
   - `buyingPath`: An array of token addresses representing the swap path of the buying DEX.
   - `sellingPath`: An array of token addresses representing the swap path of the selling DEX.
   - `amount`: The amount of the flash loan.

3. Call the `executeTriangularFlashLoan` function to perform a triangular flash loan. Only the contract owner can execute this function. Provide the following parameters:
   - `dexAddresses`: An array of three addresses representing the buying, selling, and intermediate DEXes.
   - `buyingPath`: An array of token addresses representing the swap path of the buying DEX.
   - `intermediatePath`: An array of token addresses representing the swap path of the intermediate DEX.
   - `sellingPath`: An array of token addresses representing the swap path of the selling DEX.
   - `amount`: The amount of the flash loan.

Note: Make sure to set the appropriate allowances for the SimpleFlashLoan contract to interact with the DEXes and Aave protocol.

The flash loan execution happens in the `executeOperation` function, which is called by Aave. It performs the swapping operations using Uniswap based on the provided parameters.

Please ensure that you understand the risks associated with flash loans and the specific implementation details before using the SimpleFlashLoan contract.
