pragma solidity ^0.5.6;

import "./Roles.sol";

contract LockerRole {
    using Roles for Roles.Role;

    event LockerAdded(address indexed account);
    event LockerRemoved(address indexed account);

    Roles.Role private _lockers;

    constructor () internal {
        _lockers.init();
        _addLocker(msg.sender);
    }

    modifier onlyLocker() {
        require(isLocker(msg.sender), "LockerRole: caller does not have the Locker role");
        _;
    }

    function isLocker(address account) public view returns (bool) {
        return _lockers.has(account);
    }

    function addLocker(address account) public onlyLocker {
        _addLocker(account);
    }

    function renounceLocker() public {
        _removeLocker(msg.sender);
    }
    
    function getLockerCount() public view returns (uint256) {
        return _lockers.getCount();
    }

    function _addLocker(address account) internal {
        _lockers.add(account);
        emit LockerAdded(account);
    }

    function _removeLocker(address account) internal {
        _lockers.remove(account);
        emit LockerRemoved(account);
    }
}