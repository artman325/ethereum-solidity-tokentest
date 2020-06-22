pragma solidity ^0.5.0;
// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    /**
      * @dev Allows the current owner to transfer control of the contract to a newOwner.
      * @param newOwner The address to transfer ownership to.
      */
    // function transferOwnership(address newOwner) public onlyOwner {
    //     _transferOwnership(newOwner);
    // }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}