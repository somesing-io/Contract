pragma solidity ^0.5.6;

import "./Roles.sol";

contract BrokerRole {
    using Roles for Roles.Role;

    event BrokerAdded(address indexed account);
    event BrokerRemoved(address indexed account);

    Roles.Role private _brokers;

    constructor () internal {
        _brokers.init();
        _addBroker(msg.sender);
    }

    modifier onlyBroker() {
        require(isBroker(msg.sender), "BrokerRole: caller does not have the Broker role");
        _;
    }

    function isBroker(address account) public view returns (bool) {
        return _brokers.has(account);
    }

    function addBroker(address account) public onlyBroker {
        _addBroker(account);
    }

    function renounceBroker() public {
        _removeBroker(msg.sender);
    }
    
    function getBrokerCount() public view returns (int8) {
        return _brokers.getCount();
    }

    function _addBroker(address account) internal {
        _brokers.add(account);
        emit BrokerAdded(account);
    }

    function _removeBroker(address account) internal {
        _brokers.remove(account);
        emit BrokerRemoved(account);
    }
}