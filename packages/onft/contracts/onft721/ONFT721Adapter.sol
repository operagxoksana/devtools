// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import { ONFT721Core } from "./ONFT721Core.sol";

abstract contract ONFT721Adapter is ONFT721Core, IERC721Receiver {
    IERC721 internal immutable innerToken;

    constructor(address _token, address _lzEndpoint, address _delegate) ONFT721Core(_lzEndpoint, _delegate) {
        innerToken = IERC721(_token);
    }

    function token() external view returns (address) {
        return address(innerToken);
    }

    // TODO apply the same changes from `ONFT721.sol` to this function.
    function _debit(uint256 _tokenId, uint32 /*_dstEid*/) internal virtual override {
        innerToken.safeTransferFrom(msg.sender, address(this), _tokenId);
    }

    // TODO apply the same changes from `ONFT721.sol` to this function.
    function _credit(address _toAddress, uint256 _tokenId, uint32 /*_srcEid*/) internal virtual override {
        innerToken.safeTransferFrom(address(this), _toAddress, _tokenId);
    }

    function onERC721Received(address _operator, address, uint, bytes memory) public virtual override returns (bytes4) {
        // only allow `this` to transfer token from others
        if (_operator != address(this)) return bytes4(0);
        return IERC721Receiver.onERC721Received.selector;
    }

    function approvalRequired() external pure virtual returns (bool) {
        return true;
    }
}
