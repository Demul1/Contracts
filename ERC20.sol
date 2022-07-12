
pragma solidity ^0.4.24;
 
import "./SafeMath.sol";
import "./ERC20Interface.sol";
import "./ApproveAndCallFallBack.sol";
import "./ThisAddress.sol";
import "./Ownable.sol";
 
//Actual token contract

contract ERC20 is ERC20Interface, SafeMath, Ownable, ThisAddress {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    address public Owner;
 
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
 
    constructor() public {
        symbol = "ERC";
        name = "ERC20";
        decimals = 18;
        _totalSupply = safeMul(100000000, 1000000000000000000);
        Owner = msg.sender;
        balances[Owner] = _totalSupply;
        emit Transfer(address(0), Owner, _totalSupply);
    }
    
    function thisAddress() public constant returns (address) { 
        return address(this);
    }
    function totalSupply() public constant returns (uint) { 
        return _totalSupply  - balances[address(0)];
    }
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }
 
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        //allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    function burn(address burner, uint tokens) public returns (bool success) {
        require(msg.sender==burner, 'You can only burn your own Demula!');
        require(balances[burner]>=tokens, 'Not enough Demula!');
        balances[burner] = safeSub(balances[burner], tokens);
        _totalSupply = safeSub(_totalSupply, tokens);
        emit Transfer(burner, address(0), tokens);
        return true;
    }
    function mint(address to, uint tokens) public returns (bool success) {
        require(msg.sender==Owner, 'You are not the owner!');
        balances[to] = safeAdd(balances[to], tokens);
        _totalSupply = safeAdd(_totalSupply, tokens);
        emit Transfer(address(0), to, tokens);
        return true;
    }
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
 
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    function transferOwnership(address newOwner) public returns (bool success) 
    {
        require(msg.sender==Owner, 'You are not the owner!');
        Owner = newOwner;
        return true;
    }
    function Owner() external constant returns (address)
    {
        return Owner;
    }
    function () public payable {
        revert();
    }
}
