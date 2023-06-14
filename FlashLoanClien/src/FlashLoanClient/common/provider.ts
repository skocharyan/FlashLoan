import { SimpleFlashLoan, SimpleFlashLoan__factory } from "@metadata";
import * as dotenv from "dotenv";
import { isPathCorrect } from "./utils";
import { BigNumber } from "ethers";
import path from "path";

const ethers = require("ethers");

dotenv.config();

export class FlashLoanContract {
  private static instance: FlashLoanContract | undefined;
  private FlashLoanContract: SimpleFlashLoan;

  private constructor() {
    const provider = new ethers.providers.JsonRpcProvider();
    const mnemonicWallet = ethers.Wallet.fromMnemonic(
      process.env.mnemonic,
      `m/44'/60'/0'/0/${process.env.accountIndex}`
    );
    const wallet = mnemonicWallet.connect(provider);

    this.FlashLoanContract = new ethers.Contract(
      process.env.contractAddress,
      SimpleFlashLoan__factory.abi,
      wallet
    );
  }
  public static createInstance(): FlashLoanContract {
    if (!this.instance) {
      this.instance = new FlashLoanContract();
      return this.instance;
    }
    return this.instance;
  }

  // Amount should be represented in ETH (not WEI)
  public async initSimpleFlashLoan(
    dexesAddresses: ["string", "string"],
    paths: [string[], string[]],
    amount: number
  ): Promise<string> {
    if (dexesAddresses.length !== paths.length) {
      throw new Error("Invalid dex addresses count");
    }
    if (!isPathCorrect(paths)) {
      throw new Error("Invalid path");
    }

    const weiAmount: BigNumber = ethers.utils.parseEther(amount.toString());
    const tx = await this.FlashLoanContract.executeSimpleFlashLoan(
      dexesAddresses,
      paths[0],
      paths[1],
      weiAmount
    );
    tx.wait; // Wait for the transaction to be verified
    return tx.hash;
  }

  public async initTriangleFlashLoan(
    dexesAddresses: ["string", "string", "string"],
    paths: [string[], string[], string[]],
    amount: number
  ): Promise<string> {
    if (dexesAddresses.length !== paths.length) {
      throw new Error("Invalid dex addresses count");
    }
    if (!isPathCorrect(paths)) {
      throw new Error("Invalid path");
    }

    // Paths[2] is an intermediate path.
    const weiAmount: BigNumber = ethers.utils.parseEther(amount.toString());

    const tx = await this.FlashLoanContract.executeTriangularFlashLoan(
      dexesAddresses,
      paths[0],
      paths[1],
      paths[2],
      weiAmount
    );
    tx.wait; // Wait for the transaction to be verified
    return tx.hash;
  }
}
