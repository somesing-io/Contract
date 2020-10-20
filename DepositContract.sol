pragma solidity ^0.5.6;

import "./BrokerRole.sol";

/// @title KIP-7 Fungible Token Standard, optional wallet interface
/// @dev Note: the KIP-13 identifier for this interface is 0x9d188c22.
interface IKIP7TokenReceiver {
    /// @notice Handle the receipt of KIP-7 token
    /// @dev The KIP-7 smart contract calls this function on the recipient
    ///  after a `safeTransfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _amount The token amount which is being transferred.
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onKIP7Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    function onKIP7Received(address _operator, address _from, uint256 _amount, bytes calldata _data) external returns(bytes4);
}

interface TokenContractInterface {
    function safeTransfer(address recipient, uint256 amount) external;
}


contract DepositContract is IKIP7TokenReceiver, BrokerRole {
    
    string constant public version = "v1.00";
    address private addrTokenContract;

    uint8 constant REQTYPE_DEPOSIT = 1;
    uint8 constant REQTYPE_DEPOSIT_BYSS = 11;
    uint8 constant REQTYPE_SYSTEM_DEPOSIT = 30;


    constructor(address _addrTokenContract) public {
        addrTokenContract = _addrTokenContract;
    }    
    
    mapping(address => uint256) depositList;
    
    
    event EventDeposited(address _address, uint256 _amount);
    event EventWithdrawn(address _address, uint256 _amount);
    event EventWithdrawnTo(address _address, address _to, uint256 _amount);
    event EventWithdrawnAmount(address receipient, uint256 amount);
    event EventAddressChanged(address _from, address _to);
    
    
    /*
        EXTERNAL FUNCTIONS
    */  
    
    function setTokenContractAddress(address _addrTokenContract) external onlyBroker {
        addrTokenContract = _addrTokenContract;
    }
    
    function getTokenContractAddress() external view returns(address){
        return addrTokenContract;
    }
    
    function withdrawAmount(address receipient, uint256 amount) external onlyBroker{
        require(amount > 0, "amount is zero");
        require(receipient != address(0), "transfer to the zero address");
        _transfer(receipient, amount);
        emit EventWithdrawnAmount(receipient, amount);
    }
    
    function withdraw(address _address) external onlyBroker {
        uint256 amount = depositList[_address];
        require(amount > 0, "not deposited");
        _transfer(_address, amount);
        depositList[_address] = 0;
        emit EventWithdrawn(_address, amount);
    }
    
     function withdrawTo(address _addrUser, address _addrTo) external onlyBroker {
        uint256 amount = depositList[_addrUser];
        require(amount > 0, "not deposited");
        _transfer(_addrTo, amount);
        depositList[_addrUser] = 0;
        emit EventWithdrawnTo(_addrUser, _addrTo, amount);
    }   
    
    function changeAddress(address _from, address _to) external onlyBroker {
        require(_isDeposited(_from), "not deposited");
        depositList[_to] = depositList[_from];
        depositList[_from] = 0;
        emit EventAddressChanged(_from, _to);
    }
    
    function getDepositAmount(address _address) external view returns(uint256) {
        return depositList[_address];
    }
    
    /*
        INTERNAL FUNCTIONS
    */
    
    function bytesToAddress(bytes memory _bytes, uint _byteArrayOffset) internal pure returns (address addr) {
        assembly {
          addr := mload(add(_bytes, add(20, _byteArrayOffset)))
        } 
    }
    
    function _transfer(address _to, uint256 _amount) internal {
        if ( _amount > 0 ) {
            TokenContractInterface tci = TokenContractInterface(addrTokenContract);
            tci.safeTransfer(_to, _amount);
        }
    }

    function _isDeposited(address _address) internal view returns(bool) {
        return (depositList[_address] > 0);
        
    }
    
    function _deposit(address _address, uint256 _amount) internal {
        require(_isDeposited(_address) == false, "already deposited");
        depositList[_address] = _amount;
        emit EventDeposited(_address, _amount);
    }

    function onKIP7Received(address /*_operator*/, address _from, uint256 _amount, bytes calldata _data) external returns(bytes4) {
        require(msg.sender == addrTokenContract, "not from token contract");
        require(_amount > 0, "deposit amount is zero");
        
        uint16 offset = 0;
        uint8 reqType = uint8(_data[0]);
        offset++;
        
        if ( reqType == REQTYPE_DEPOSIT) {
            _deposit(_from, _amount);
        } else if ( reqType == REQTYPE_DEPOSIT_BYSS) {
            address addrUser = bytesToAddress(_data, offset);
            _deposit(addrUser, _amount);
        } else if ( reqType == REQTYPE_SYSTEM_DEPOSIT ) {
            // nothing to do
        }else {
            revert("Invalid request type!~");
        }
        return 0x9d188c22;
    }   
    
    
    
    
    
}