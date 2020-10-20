pragma solidity ^0.5.6;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        uint256 count;
        mapping (address => bool) bearer;
    }
    
    function init(Role storage role) internal{
        role.count = 0;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.count++;
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        require(getCount(role) > 1, "Roles: manager only one" );
        role.count--;
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
    
    function getCount(Role storage role) internal view returns (uint256){
        return role.count;
    }
}
