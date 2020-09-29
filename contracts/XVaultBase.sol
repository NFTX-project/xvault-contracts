// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.7.0;

import "./Pausable.sol";
import "./IXToken.sol";
import "./IERC721.sol";
import "./CryptoPunksMarket.sol";

contract XVaultBase is Pausable {
    address private erc20Address;
    // address private erc721Address;
    address private cpmAddress;

    IXToken private erc20;
    // IERC721 private erc721;
    CryptoPunksMarket private cpm;

    function getERC20Address() public view returns (address) {
        return erc20Address;
    }

    /* function getERC721Address() public view returns (address) {
        return erc721Address;
    } */

    function getCpmAddress() public view returns (address) {
        return cpmAddress;
    }

    function getERC20() internal view returns (IXToken) {
        return erc20;
    }

    /* function getERC721() internal view returns (IERC721) {
        return erc721;
    } */

    function getCPM() internal view returns (CryptoPunksMarket) {
        return cpm;
    }

    function setERC20Address(address newAddress) internal {
        require(erc20Address == address(0), "Already initialized ERC20");
        erc20Address = newAddress;
        erc20 = IXToken(erc20Address);
    }

    /* function setERC721Address(address newAddress) internal {
        require(erc721Address == address(0), "Already initialized ERC20");
        erc721Address = newAddress;
        erc721 = IERC721(erc721Address);
    } */

    function setCpmAddress(address newAddress) internal {
        require(cpmAddress == address(0), "Already initialized CPM");
        cpmAddress = newAddress;
        cpm = CryptoPunksMarket(cpmAddress);
    }
}
