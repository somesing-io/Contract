pragma solidity ^0.5.6;

import "./KIP7Mintable.sol";
import "./KIP7Burnable.sol";
import "./KIP7Pausable.sol";
import "./KIP7Metadata.sol";
import "./KIP7Lockable.sol";

contract KIP7Token is KIP7Mintable, KIP7Burnable, KIP7Pausable, KIP7Metadata, KIP7Lockable {
    constructor(string memory name, string memory symbol) KIP7Metadata(name, symbol, 18) public {
        _mint(msg.sender, 5000000000000000000000000000);
    }
}
