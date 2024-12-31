// what are our invariants? Properties of the system that should always hold

// 1. the total supply of DSC should be less than the total value of collateral

// 2. Getter view functions should never revert <- evergreen invariant

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDSC} from "../../script/DepolyDSC.s.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStablecoin} from "../../src/DecentralizedStablecoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Handler} from "./Handler.t.sol";

contract Invariants is StdInvariant, Test {
    DeployDSC deployer;
    DSCEngine dsce;
    DecentralizedStablecoin dsc;
    HelperConfig config;
    address weth;
    address wbtc;
    Handler handler;

    function setUp() external {
        deployer = new DeployDSC();
        (dsc, dsce, config) = deployer.run();
        (,, weth, wbtc,) = config.activeNetworkConfig();
        // targetContract(address(dsce));
        handler = new Handler(dsce, dsc);
        targetContract(address(handler));
    }

    function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
        // get the value of all the collateral in the protocol
        // compare it to all the debt (dsc)
        uint256 totalSupply = dsc.totalSupply();
        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(dsce));
        uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(dsce));

        uint256 wethValue = dsce.getUsdValue(weth, totalWethDeposited);
        uint256 wbtcValue = dsce.getUsdValue(wbtc, totalWbtcDeposited);

        console.log("total supply: ", totalSupply);
        console.log("times mint called: ", handler.timesMintIsCalled());

        assert(wethValue + wbtcValue >= totalSupply);
    }

    function invariant_gettersShouldNotRevert() public view {
        dsce.getLiquidationBonus();
        dsce.getPrecision();

        /**
         * getAccountCollateralValue(address)": "7d1a4450",
         *   "getAccountInformation(address)": "7be564fc",
         *   "getAdditionalFeedPrecision()": "8f63d667",
         *   "getCollateralBalanceOfUser(address,address)": "31e92b83",
         *   "getCollateralTokenPriceFeed(address)": "1c08adda",
         *   "getCollateralTokens()": "b58eb63f",
         *   "getDsc()": "deb8e018",
         *   "getHealthFactor(address)": "fe6bcd7c",
         *   "getLiquidationBonus()": "59aa9e72",
         *   "getLiquidationPrecision()": "6c8102c0",
         *   "getLiquidationThreshold()": "4ae9b8bc",
         *   "getMinHealthFactor()": "8c1ae6c8",
         *   "getPrecision()": "9670c0bc",
         *   "getTokenAmountFromUsd(address,uint256)": "afea2e48",
         *   "getUsdValue(address,uint256)"
         */
    }
}
