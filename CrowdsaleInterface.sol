pragma solidity ^0.5.0;

contract CrowdsaleInterface {

    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;

    mapping(address => uint8) whitelist;
    mapping(uint256 => address) holders;
    mapping(address => uint) maxInvestLimitList;

    uint256 _totalHolders; // you should initialize this to 0 in the constructor

    function enableWhitelist(address[] memory _addresses) public returns (bool success);
    function setMaximumInvest(address _address, uint _amount) public returns (bool success);

    modifier onlyWhitelist() {
        require(whitelist[msg.sender] == 2);
        _;
    }




}