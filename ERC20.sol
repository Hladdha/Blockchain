// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function TotalSupply() external view returns (uint);

    function BalanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function Allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


contract ERC20 is IERC20 {

    string private name;
    string private symbol;
    uint private totalSupply;
    mapping(address => uint) private balanceOf;
    mapping(address => mapping(address => uint)) private allowance;
    uint8 private decimals = 18;
    address public account; 

    constructor (string memory _name , string memory _symbol){
        name = _name;
        symbol = _symbol;
        account = msg.sender;
    }

    function Name() public view returns (string memory){
        return name;
    }

    function Symbol() public view returns (string memory){
        return symbol;
    }

    function Decimals() public view returns (uint8){
        return decimals;
    }

    function TotalSupply() public view returns (uint256){
        return totalSupply;
    }

    function transfer(address recipient, uint amount) external returns (bool) {
        if( balanceOf[msg.sender] >= amount){
            balanceOf[msg.sender] -= amount;
            balanceOf[recipient] += amount;
            emit Transfer(msg.sender, recipient, amount);
            return true;
        }
        else {
            return false;
        }
    }

    function BalanceOf(address _owner) public view returns (uint256 balance){
        return balanceOf[_owner];
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success){
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender , _spender , _value);
        return true;
    }

    function Allowance(address _owner, address _spender) public view returns (uint256 remaining){
        return allowance[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        if (Allowance(_from , msg.sender) >= _value){
            uint change = Allowance(_from , msg.sender) - _value;
            approve(msg.sender , change);
            balanceOf[msg.sender] -= _value;
            balanceOf[_to] += _value;
            emit Transfer(_from , _to , _value);
            return true;
        }
        else {
            return false;
        }
    }

    function _mint(address minter , uint amount) internal {
        require(minter != account , "not allowed to mint");

        totalSupply += amount;
        balanceOf[minter] += amount;

        emit Transfer(minter, minter, amount); 
    }
}