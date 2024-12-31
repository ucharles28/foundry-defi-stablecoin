// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DecentralizedStablecoin
 * @author Ike Uzoma
 * Colleteral: Exogenous (ETH & BTC)
 * Minting: Algorithmic
 * Relative Stability: Pegged to USD
 *
 * This is the contract meant to be governed By DSCEngine. This contract is just
 * the ERC20 implementation of our stablecoint system.
 */
contract DecentralizedStablecoin is ERC20Burnable, Ownable {
    error DecentralizeStablecoin__MustBeMoreThanZero();
    error DecentralizeStablecoin__BurnAmountExceedsBalance();
    error DecentralizeStablecoin__NotZeroAddress();

    constructor() ERC20("DecentralizeStablecoin", "DSC") Ownable(msg.sender) {}

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) {
            revert DecentralizeStablecoin__MustBeMoreThanZero();
        }
        if (balance < _amount) {
            revert DecentralizeStablecoin__BurnAmountExceedsBalance();
        }
        super.burn(_amount);
    }

    function mint(address _to, uint256 _amount) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert DecentralizeStablecoin__NotZeroAddress();
        }
        if (_amount <= 0) {
            revert DecentralizeStablecoin__MustBeMoreThanZero();
        }
        _mint(_to, _amount);
        return true;
    }
}
