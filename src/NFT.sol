// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract NFT {
    error Invalid_Address();
    error Token_Does_Not_Exist();
    error Not_Authorized();
    error Not_approved();

    string public name;
    string public symbol;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    mapping(uint256 => string) private _tokenURIs;
    uint256 public tokenIdCounter;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert Invalid_Address();
        }

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        if (owner == address(0)) {
            revert Token_Does_Not_Exist();
        }
        return owner;
    }

    function transferFrom(address from, address to, uint256 tokenId) external {
        address owner = ownerOf(tokenId);
        if (msg.sender != owner || !isApprovedForAll(msg.sender, owner)) {
            revert Not_Authorized();
        }
        _transfer(from, to, tokenId);
    }

    function approve(address to, uint256 tokenId) external {
        address owner = ownerOf(tokenId);

        if (msg.sender != owner || !isApprovedForAll(msg.sender, owner)) {
            revert Not_Authorized();
        }
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function balanceOf() external view returns (uint256) {
        if (msg.sender == address(0)) {
            revert Invalid_Address();
        }

        return _balances[msg.sender];
    }

    function getApprove(uint256 tokenId) public view returns (address) {
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) external {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view {
        address owner = ownerOf(tokenId);

        if (spender != owner && getApprove(tokenId) != spender && !isApprovedForAll(owner, spender)) {
            revert Not_approved();
        }
    }

    function mint(address to, string memory uri) public {
        if (to == address(0)) {
            revert Invalid_Address();
        }

        uint256 tokenId = tokenIdCounter;
        tokenIdCounter += 1;

        _balances[to] += 1;
        _owners[tokenId] = to;
        _tokenURIs[tokenId] = uri;

        emit Transfer(address(0), to, tokenId);
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        if (_owners[tokenId] == address(0)) {
            revert Token_Does_Not_Exist();
        }
        return string(abi.encodePacked("ipfs://", _tokenURIs[tokenId]));
    }
}
