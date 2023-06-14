// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract SimpleFlashLoan is FlashLoanSimpleReceiverBase, Ownable {
    event Log(address[] data, string desc);

    constructor(
        address _addressProvider
    ) FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider)) {}

    /// @notice Executes simple flash  loan
    /// @dev This function encodes the parameters, passes them to the flash loan smart contract, and triggers the flash loan
    /// @param dexAddresses The addresses of the buying and selling DEXes
    /// @param buyingPath The swap path of the buying DEX
    /// @param sellingPath The swap path of the selling DEX
    /// @param amount The amount of the flash loan
    function executeSimpleFlashLoan(
        address[] calldata dexAddresses,
        address[] calldata buyingPath,
        address[] calldata sellingPath,
        uint256 amount
    ) external onlyOwner {
        // The token  which we borrow from AAVE
        require(
            dexAddresses.length == 2,
            "There should be two DEXes for double swapping"
        );
        address asset = buyingPath[0];

        bytes memory encodedParams = abi.encode(
            dexAddresses,
            buyingPath,
            buyingPath,
            sellingPath
        );

        // Request the flash loan
        requestFlashLoan(asset, amount, encodedParams);
    }

    /// @notice Executes simple flash  loan
    /// @dev This function encodes the parameters, passes them to the flash loan smart contract, and triggers the flash loan
    /// @param dexAddresses The addresses of the buying , selling and intermediate  DEXes
    /// @param buyingPath The swap path of the buying DEX
    /// @param intermediatePath The swap path of the intermediate  DEX
    /// @param sellingPath The swap path of the selling DEX
    /// @param amount The amount of the flash loan
    function executeTriangularFlashLoan(
        address[] calldata dexAddresses,
        address[] calldata buyingPath,
        address[] calldata intermediatePath,
        address[] calldata sellingPath,
        uint256 amount
    ) external onlyOwner {
        require(
            dexAddresses.length == 3,
            "There should be three DEXes for triple swapping"
        );
        // The token  which we borrow from AAVE
        address asset = buyingPath[0];

        bytes memory encodeParams = abi.encode(
            dexAddresses,
            buyingPath,
            intermediatePath,
            sellingPath
        );
        requestFlashLoan(asset, amount, encodeParams);
    }

    function requestFlashLoan(
        address _token,
        uint256 _amount,
        bytes memory params
    ) private {
        address receiverAddress = address(this);
        address asset = _token;
        uint256 amount = _amount;

        uint16 referralCode = 0;

        POOL.flashLoanSimple(
            receiverAddress,
            asset,
            amount,
            params,
            referralCode
        );
    }

    /// @notice Executes the operation
    /// @dev This function is called by AAVE to execute the flash loan
    /// @param asset The address of the borrowed token
    /// @param amount The amount of the borrowed asset
    /// @param premium The fee we should pay for the flash loan
    /// @param initiator The address of the flash loan initiator
    /// @param encodeParams The encoded data used to execute the flash loan
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata encodeParams
    ) external override returns (bool) {
        address[] memory dexAddresses;
        address[] memory buyingPath;
        address[] memory intermediatePath;
        address[] memory sellingPath;
        // Decode params
        (dexAddresses, buyingPath, intermediatePath, sellingPath) = abi.decode(
            encodeParams,
            (address[], address[], address[], address[])
        );

        if (dexAddresses.length == 2) {
            doubleSwap(dexAddresses, buyingPath, sellingPath);
        } else {
            tripleSwap(dexAddresses, buyingPath, intermediatePath, sellingPath);
        }

        uint256 assetBalnace = IERC20(asset).balanceOf(address(this));
        uint256 totalAmount = amount + premium;

        require(assetBalnace >= totalAmount, "Invalid asset balance!");

        IERC20(asset).approve(address(POOL), totalAmount);
        IERC20(asset).transfer(owner(), assetBalnace - totalAmount);

        return true;
    }

    function doubleSwap(
        address[] memory dexAddresses,
        address[] memory buyingPath,
        address[] memory sellingPath
    ) private {
        IUniswapV2Router02 buyingDex = IUniswapV2Router02(dexAddresses[0]);
        IUniswapV2Router02 sellingDex = IUniswapV2Router02(dexAddresses[1]);

        uint buyingTokenAmount = IERC20(buyingPath[0]).balanceOf(address(this));
        IERC20(buyingPath[0]).approve(dexAddresses[0], buyingTokenAmount);

        // Make first swapping
        buyingDex.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            buyingTokenAmount,
            0,
            buyingPath,
            address(this),
            block.timestamp + 120
        );

        uint sellingAmount = IERC20(sellingPath[0]).balanceOf(address(this));
        IERC20(sellingPath[0]).approve(dexAddresses[1], sellingAmount);

        // Make second swapping
        sellingDex.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            sellingAmount,
            0,
            sellingPath,
            address(this),
            block.timestamp + 120
        );
    }

    function tripleSwap(
        address[] memory dexAddresses,
        address[] memory buyingPath,
        address[] memory intermediatePath,
        address[] memory sellingPath
    ) private {
        IUniswapV2Router02 buyingDex = IUniswapV2Router02(dexAddresses[0]);
        IUniswapV2Router02 middleDex = IUniswapV2Router02(dexAddresses[1]);
        IUniswapV2Router02 sellingDex = IUniswapV2Router02(dexAddresses[2]);

        uint buyingTokenAmount = IERC20(buyingPath[0]).balanceOf(address(this));
        IERC20(buyingPath[0]).approve(dexAddresses[0], buyingTokenAmount);

        // Make first swapping
        buyingDex.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            buyingTokenAmount,
            0,
            buyingPath,
            address(this),
            block.timestamp + 120
        );

        uint intermediateTokenAmount = IERC20(intermediatePath[0]).balanceOf(
            address(this)
        );
        IERC20(intermediatePath[0]).approve(
            dexAddresses[1],
            intermediateTokenAmount
        );

        middleDex.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            intermediateTokenAmount,
            0,
            intermediatePath,
            address(this),
            block.timestamp + 120
        );

        uint sellingAmount = IERC20(sellingPath[0]).balanceOf(address(this));
        IERC20(sellingPath[0]).approve(dexAddresses[2], sellingAmount);

        sellingDex.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            sellingAmount,
            0,
            sellingPath,
            address(this),
            block.timestamp + 120
        );
    }
}
