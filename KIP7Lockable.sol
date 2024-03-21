pragma solidity ^0.5.6;

import "./KIP7.sol";
import "./KIP13.sol";
import "./LockerRole.sol";



contract KIP7Lockable is KIP13, KIP7,LockerRole {
    
    /*
     *     bytes4(keccak256('distribute(address,uint256)')) == 0xfb932108
     *     bytes4(keccak256('unLock(address,uint256)')) == 0x16a59ed0
     *     bytes4(keccak256('dispossess(address,uint256)')) == 0x3cf2eb85
     *
     *     => 0xfb932108 ^ 0x16a59ed0 ^ 0x3cf2eb85 == 0xd1c4545d
     */
    bytes4 private constant _INTERFACE_ID_KIP7_LOCKABLE = 0xd1c4545d;

    /**
     * @dev Constructor function.
     */
    constructor () public {
        // register the supported interface to conform to KIP17Burnable via KIP13
        _registerInterface(_INTERFACE_ID_KIP7_LOCKABLE);
    }
    
    
    function distribute(address recipient, uint256 amount) public onlyLocker returns (bool){
        _distribute(msg.sender, recipient, amount);
        return true;
    }
    
    function unLock(address account, uint256 amount) public onlyLocker returns (bool){
        _unlock(account, amount);
        return true;
    }
    
    function dispossess(address account, uint256 amount) public onlyLocker returns (bool){
        _dispossess(account, amount);
        return true;
    }
    
}
