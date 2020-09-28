// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.7.0;

import "./Manageable.sol";
import "./ERC721Holder.sol";
import "./utils/console.sol";

contract XVault is Manageable, ERC721Holder {
    event TokenMinted(uint256 tokenId, address indexed to);
    event TokensMinted(uint256[] tokenIds, address indexed to);
    event TokenBurned(uint256 tokenId, address indexed to);
    event TokensBurned(uint256[] tokenIds, address indexed to);

    constructor(address erc20Address, address erc721Address) public {
        setERC20Address(erc20Address);
        setERC721Address(erc721Address);
    }

    function getERC721AtIndex(uint256 index) public view returns (uint256) {
        return getReserves().at(index);
    }

    function getReservesLength() public view returns (uint256) {
        return getReserves().length();
    }

    function isERC721Deposited(uint256 tokenId) public view returns (bool) {
        return getReserves().contains(tokenId);
    }

    function mintERC20(uint256 tokenId)
        public
        payable
        nonReentrant
        whenNotPaused
    {
        uint256 fee = getFee(_msgSender(), 1, getMintFees());
        require(msg.value >= fee, "Value too low");
        _mintERC20(tokenId, false);
    }

    function _mintERC20(uint256 tokenId, bool partOfDualOp)
        private
        returns (bool)
    {
        address msgSender = _msgSender();
        require(getERC721().ownerOf(tokenId) == msgSender, "Not NFT owner");
        require(
            (getERC721().getApproved(tokenId) == address(this)) ||
                (getERC721().isApprovedForAll(msgSender, address(this))),
            "Not approved"
        );
        getERC721().safeTransferFrom(_msgSender(), address(this), tokenId);
        getReserves().add(tokenId);
        if (!partOfDualOp) {
            uint256 tokenAmount = 10**18;
            getERC20().mint(msgSender, tokenAmount);
        }
        emit TokenMinted(tokenId, _msgSender());
        return true;
    }

    function mintERC20s(uint256[] memory tokenIds)
        public
        payable
        nonReentrant
        whenNotPaused
    {
        uint256 fee = getFee(_msgSender(), tokenIds.length, getMintFees());
        require(msg.value >= fee, "Value too low");
        _mintERC20s(tokenIds, false);
    }

    function _mintERC20s(uint256[] memory tokenIds, bool partOfDualOp)
        private
        returns (uint256)
    {
        require(tokenIds.length > 0, "No tokens");
        require(tokenIds.length <= 100, "Over 100 tokens");
        uint256[] memory newTokenIds = new uint256[](tokenIds.length);
        uint256 numNewTokens = 0;
        address msgSender = _msgSender();
        bool approvedForAll = getERC721().isApprovedForAll(
            msgSender,
            address(this)
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            bool isApproved = approvedForAll ||
                (getERC721().getApproved(tokenId) == address(this));
            bool isOwner = getERC721().ownerOf(tokenId) == msgSender;
            if (isApproved || isOwner) {
                getERC721().safeTransferFrom(msgSender, address(this), tokenId);
                getReserves().add(tokenId);
                newTokenIds[numNewTokens] = tokenId;
                numNewTokens = numNewTokens.add(1);
            }
        }
        if (numNewTokens > 0) {
            if (!partOfDualOp) {
                uint256 tokenAmount = numNewTokens * (10**18);
                getERC20().mint(msgSender, tokenAmount);
            }
            emit TokensMinted(newTokenIds, msgSender);
        }
        return numNewTokens;
    }

    function redeemERC721() public payable nonReentrant whenNotPaused {
        uint256 fee = getFee(_msgSender(), 1, getBurnFees());
        require(msg.value >= fee, "Value too low");
        _redeemERC721(false);
    }

    function _redeemERC721(bool partOfDualOp) private {
        address msgSender = _msgSender();
        uint256 tokenAmount = 10**18;
        require(
            partOfDualOp || (getERC20().balanceOf(msgSender) >= tokenAmount),
            "ERC20 balance too small"
        );
        require(
            partOfDualOp ||
                (getERC20().allowance(msgSender, address(this)) >= tokenAmount),
            "ERC20 allowance too small"
        );
        uint256 reservesLength = getReserves().length();
        uint256 randomIndex = getPseudoRand(reservesLength);
        uint256 tokenId = getReserves().at(randomIndex);
        if (!partOfDualOp) {
            getERC20().burnFrom(msgSender, tokenAmount);
        }
        getReserves().remove(tokenId);
        getERC721().safeTransferFrom(address(this), msgSender, tokenId);
        emit TokenBurned(tokenId, msgSender);
    }

    function redeemERC721s(uint256 numTokens)
        public
        payable
        nonReentrant
        whenNotPaused
    {
        uint256 fee = getFee(_msgSender(), numTokens, getBurnFees());
        require(msg.value >= fee, "Value too low");
        _redeemERC721s(numTokens, false);
    }

    function _redeemERC721s(uint256 numTokens, bool partOfDualOp) private {
        require(numTokens > 0, "No tokens");
        require(numTokens <= 100, "Over 100 tokens");
        address msgSender = _msgSender();
        uint256 tokenAmount = numTokens * (10**18);
        require(
            partOfDualOp || (getERC20().balanceOf(msgSender) >= tokenAmount),
            "ERC20 balance too small"
        );
        require(
            partOfDualOp ||
                (getERC20().allowance(msgSender, address(this)) >= tokenAmount),
            "ERC20 allowance too small"
        );
        if (!partOfDualOp) {
            getERC20().burnFrom(msgSender, tokenAmount);
        }
        uint256[] memory tokenIds = new uint256[](numTokens);
        for (uint256 i = 0; i < numTokens; i++) {
            uint256 reservesLength = getReserves().length();
            uint256 randomIndex = getPseudoRand(reservesLength);
            uint256 tokenId = getReserves().at(randomIndex);
            tokenIds[i] = tokenId;
            getReserves().remove(tokenId);
            getERC721().safeTransferFrom(address(this), msgSender, tokenId);
        }
        emit TokensBurned(tokenIds, msgSender);
    }

    function mintAndRedeem(uint256 tokenId)
        public
        payable
        nonReentrant
        whenNotPaused
    {
        uint256 fee = getFee(_msgSender(), 1, getDualFees());
        require(msg.value >= fee, "Value too low");
        require(_mintERC20(tokenId, true), "Minting failed");
        _redeemERC721(true);
    }

    function mintAndRedeemMultiple(uint256[] memory tokenIds)
        public
        payable
        nonReentrant
        whenNotPaused
    {
        uint256 numTokens = tokenIds.length;
        require(numTokens > 0, "No tokens");
        require(numTokens <= 20, "Over 20 tokens");
        uint256 fee = getFee(_msgSender(), numTokens, getDualFees());
        require(msg.value >= fee, "Value too low");
        uint256 numTokensMinted = _mintERC20s(tokenIds, true);
        if (numTokensMinted > 0) {
            _redeemERC721s(numTokens, true);
        }
    }

    function mintRetroactively(uint256 tokenId, address to)
        public
        onlyOwner
        whenNotLockedS
    {
        require(getERC721().ownerOf(tokenId) == address(this), "Not owner");
        require(!getReserves().contains(tokenId), "Already in reserves");
        uint256 erc721Balance = getERC721().balanceOf(address(this));
        require(
            (getERC20().totalSupply() / (10**18)) < erc721Balance,
            "No excess NFTs"
        );
        getReserves().add(tokenId);
        getERC20().mint(to, 10**18);
        emit TokenMinted(tokenId, _msgSender());
    }

    function redeemRetroactively(address to) public onlyOwner whenNotLockedS {
        require(
            getERC20().balanceOf(address(this)) >= (10**18),
            "Not enough PUNK"
        );
        getERC20().burn(10**18);
        uint256 reservesLength = getReserves().length();
        uint256 randomIndex = getPseudoRand(reservesLength);

        uint256 tokenId = getReserves().at(randomIndex);
        getReserves().remove(tokenId);
        getERC721().safeTransferFrom(address(this), to, tokenId);
        emit TokenBurned(tokenId, _msgSender());
    }
}
