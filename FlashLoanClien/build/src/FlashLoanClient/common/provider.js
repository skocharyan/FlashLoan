var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
import { SimpleFlashLoan__factory } from "@metadata";
import * as dotenv from "dotenv";
import { isPathCorrect } from "./utils";
const ethers = require("ethers");
dotenv.config();
export class FlashLoanContract {
    constructor() {
        const provider = new ethers.providers.JsonRpcProvider();
        const mnemonicWallet = ethers.Wallet.fromMnemonic(process.env.mnemonic, `m/44'/60'/0'/0/${process.env.accountIndex}`);
        const wallet = mnemonicWallet.connect(provider);
        this.FlashLoanContract = new ethers.Contract(process.env.contractAddress, SimpleFlashLoan__factory.abi, wallet);
    }
    static createInstance() {
        if (!this.instance) {
            this.instance = new FlashLoanContract();
            return this.instance;
        }
        return this.instance;
    }
    // Amount should be represented in ETH (not WEI)
    initSimpleFlashLoan(dexesAddresses, paths, amount) {
        return __awaiter(this, void 0, void 0, function* () {
            if (dexesAddresses.length !== paths.length) {
                throw new Error("Invalid dex addresses count");
            }
            if (!isPathCorrect(paths)) {
                throw new Error("Invalid path");
            }
            const weiAmount = ethers.utils.parseEther(amount.toString());
            const tx = yield this.FlashLoanContract.executeSimpleFlashLoan(dexesAddresses, paths[0], paths[1], weiAmount);
            tx.wait; // Wait for the transaction to be verified
            return tx.hash;
        });
    }
    initTriangleFlashLoan(dexesAddresses, paths, amount) {
        return __awaiter(this, void 0, void 0, function* () {
            if (dexesAddresses.length !== paths.length) {
                throw new Error("Invalid dex addresses count");
            }
            if (!isPathCorrect(paths)) {
                throw new Error("Invalid path");
            }
            // Paths[2] is an intermediate path.
            const weiAmount = ethers.utils.parseEther(amount.toString());
            const tx = yield this.FlashLoanContract.executeTriangularFlashLoan(dexesAddresses, paths[0], paths[1], paths[2], weiAmount);
            tx.wait; // Wait for the transaction to be verified
            return tx.hash;
        });
    }
}
