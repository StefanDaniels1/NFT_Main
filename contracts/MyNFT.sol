// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract TestNoun is ERC721, ERC721Enumerable, Ownable {
    string private _baseURIext;
    bool public saleIsActive = false;
    uint256 public constant MAX_SUPPLY = 11;
    uint256 public constant MAX_PUBLIC_MINT = 11;
    uint256 public constant PRICE_PER_TOKEN = 0.01 ether;
    address payable public payments;

    // mapping(address => uint) balances;

    constructor(
        string memory _name,
        string memory _symbol,
        address _payments 
    )   ERC721(_name, _symbol) {
        payments = payable(_payments);
    }

    function setBaseURI(string memory baseURI_) external onlyOwner() {
        _baseURIext = baseURI_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIext;
    }

    function setSaleState(bool newState) public onlyOwner {
        saleIsActive = newState;
    }

    function mint(uint256 numberOfTokens) public payable {
        uint256 ts = totalSupply();
        require(saleIsActive, "Sale must be active to mint tokens");
        // Check whether new mint will exceed total supply.
        require(numberOfTokens <= MAX_PUBLIC_MINT);
        require(ts + numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");
        require(PRICE_PER_TOKEN * numberOfTokens <= msg.value, "Ether value sent is not correct");
        require(msg.value >= PRICE_PER_TOKEN * numberOfTokens, "Not enough Ether sent, check price");

        for (uint256 i = 0; i < numberOfTokens; i++) {
            _safeMint(msg.sender, ts + i);
        }
    }

    function _NewOwner(address newOwner) private {
        address owner = msg.sender;
        emit OwnershipTransferred(owner, newOwner);
    }

    function withdraw() public payable onlyOwner {
        uint balance = address(payments).balance;
        payable(payments).transfer(balance);
    }

    // _beforeTokenTransfer & supportsInterface are nesseccary to implement ERC721Enumerable 
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {

        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}