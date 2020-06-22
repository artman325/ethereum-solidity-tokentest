pragma solidity ^0.5.0;

import "./ERC20Interface.sol";
import "./CrowdsaleInterface.sol";
import "./Owned.sol";
import "./SafeMath.sol";

contract TestDevToken is ERC20Interface, CrowdsaleInterface, Owned {
    using SafeMath for uint;

    bytes32 public symbol;
    uint public rate;
    uint public minInvest;
    bytes32 public  name;
    uint8 public decimals;
    uint _totalSupply;
    uint amountRaised;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor(bytes32 _name, bytes32 _symbol, uint _total, uint _costEachToken, uint _minInvest) public {
        symbol = _symbol;
        name = _name;
        decimals = 18;
        rate= _costEachToken;
        minInvest= _minInvest;
        _totalSupply = _total * 10**uint(decimals);

        _totalHolders = 0;

        balances[owner] = _totalSupply;
        holders[_totalHolders] = owner;
        whitelist[owner] = 2;
        maxInvestLimitList[owner] = 0;
        _totalHolders++;


        emit Transfer(address(0), owner, _totalSupply);


    }


    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) onlyWhitelist public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) onlyWhitelist public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) onlyWhitelist public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function enableWhitelist(address[] memory _addresses) public onlyOwner returns (bool success) {
        for (uint i = 0; i < _addresses.length; i++) {
            _addWalletToWhitelist(_addresses[i]);
        }
        return true;
    }
    function _addWalletToWhitelist(address addr) internal {
        if (whitelist[addr] == 2) {
        } else if (whitelist[addr] == 1) {
            whitelist[addr] = 2;
        } else {
            whitelist[addr] = 2;
            holders[_totalHolders] = addr;
            maxInvestLimitList[addr] = 0;
            _totalHolders++;
        }
    }

    function disableWhitelist(address[] memory _addresses) public onlyOwner returns (bool success) {
        for (uint i = 0; i < _addresses.length; i++) {
            _disableWhitelist(_addresses[i]);
        }
        return true;
    }

    function _disableWhitelist(address addr) internal {
        if (whitelist[addr] == 2) {
            whitelist[addr] = 1;
        } else {
        }
    }

    function getWhitelist() public view returns (address[] memory addresses) {

        uint256 j;
        uint256 count = 0;

        for (j=0; j<_totalHolders; j++) {
            if (whitelist[holders[j]] == 2) {
                count = count+1;
            } else {
            }
        }
        address[] memory wlist = new address[](count);

        for (j=0; j<count; j++) {
            if (whitelist[holders[j]] == 2) {
                wlist[j] = holders[j];
            } else {
            }
        }
        return wlist;
    }

    function getBalances() public view returns (address[] memory _addresses, uint256[] memory _balances) {
        address[] memory wlist1 = new address[](_totalHolders);
        uint256[] memory wlist2 = new uint256[](_totalHolders);

        for (uint256 j=0; j<_totalHolders; j++) {
            //////if (whitelist[holders[j]] == 2) {
                wlist1[j] = holders[j];
                wlist2[j] = balances[holders[j]];
            //////}
        }
        return (wlist1,wlist2);
    }

    function getBalancesAndMaxLimit() public view returns (address[] memory _addresses, uint256[] memory _balances, uint256[] memory _limits) {
        address[] memory wlist1 = new address[](_totalHolders);
        uint256[] memory wlist2 = new uint256[](_totalHolders);
        uint256[] memory wlist3 = new uint256[](_totalHolders);

        for (uint256 j=0; j<_totalHolders; j++) {
            //////if (whitelist[holders[j]] == 2) {
                wlist1[j] = holders[j];
                wlist2[j] = balances[holders[j]];
                wlist3[j] = maxInvestLimitList[holders[j]];
            //////}
        }
        return (wlist1,wlist2,wlist3);
    }

    function closeCrowdsale() public onlyOwner  {
        crowdsaleClosed = true;
    }

    function safeWithdrawal() public onlyOwner {
        require(crowdsaleClosed);
        require(!fundingGoalReached);

        if (msg.sender.send(amountRaised)) {
            fundingGoalReached = true;
        } else {
            fundingGoalReached = false;
        }

    }

    // immediate withdrawal withou funding goal reached and without crowdsale close
    function immediateWithdrawal() public onlyOwner {
        if (msg.sender.send(amountRaised)) {
            //fundingGoalReached = true;
            amountRaised = 0;
        } else {
            //fundingGoalReached = false;
        }
    }

    function burnTokens(uint token_amount) public onlyOwner {

        require(!crowdsaleClosed);
        balances[owner] = balances[owner].sub(token_amount);
        _totalSupply = _totalSupply.sub(token_amount);
        emit Transfer(owner, address(0), token_amount);
    }

    function mintTokens(uint token_amount) public onlyOwner {
        require(!crowdsaleClosed);
        _totalSupply = _totalSupply.add(token_amount);
        balances[owner] = balances[owner].add(token_amount);
        emit Transfer(address(0), owner, token_amount);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(!crowdsaleClosed);

        // enable newOwner to whitelist
        _addWalletToWhitelist(newOwner);

        // puts unrealized tokens to new owner
        uint token_amount = balances[owner];
        balances[owner] = 0;
        balances[newOwner] = balances[newOwner].add(token_amount);
        emit Transfer(owner, newOwner, token_amount);

        // change owner
        _transferOwnership(newOwner);

    }

    function setMaximumInvest(address _address, uint _amount) public onlyOwner returns (bool success) {
        if (whitelist[_address] == 2) {
            maxInvestLimitList[_address] = _amount;
            return true;
        } else {
            return false;
        }
    }

    function setMinimumInvest(uint _minInvest) public onlyOwner {
        minInvest = _minInvest;
    }

    function setRate(uint _costEachToken) public onlyOwner {
        rate = _costEachToken;
    }

    function () payable onlyWhitelist external {

        require(!crowdsaleClosed);
        uint amount = msg.value;
        require(amount >= minInvest);
        require(amount.div(rate) > 0);
        require( maxInvestLimitList[msg.sender]>=amount || maxInvestLimitList[msg.sender] == 0 );

        uint token_amount = (amount.div(rate))*10**18;

        amountRaised = amountRaised.add(amount);

        balances[owner] = balances[owner].sub(token_amount);
        balances[msg.sender] = balances[msg.sender].add(token_amount);
        emit Transfer(owner, msg.sender, token_amount);

    }


}