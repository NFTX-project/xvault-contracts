// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.7.0;

import "./XVaultBase.sol";
import "./EnumerableSet.sol";
import "./ReentrancyGuard.sol";

import "./utils/console.sol";

contract XVaultSafe is XVaultBase, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.UintSet;
    EnumerableSet.UintSet private reserves;

    event TokenBurnedSafely(uint256 erc721Id, address indexed to);

    function getReserves()
        internal
        view
        returns (EnumerableSet.UintSet storage)
    {
        return reserves;
    }

    function simpleRedeem() public whenPaused nonReentrant {
        require(
            getERC20().balanceOf(msg.sender) >= 10**18,
            "ERC20 balance too small"
        );
        require(
            getERC20().allowance(msg.sender, address(this)) >= 10**18,
            "ERC20 allowance too small"
        );
        uint256 tokenId = reserves.at(0);
        getERC20().burnFrom(msg.sender, 10**18);
        reserves.remove(tokenId);
        getERC721().safeTransferFrom(address(this), msg.sender, tokenId);
        emit TokenBurnedSafely(tokenId, msg.sender);
    }
}
