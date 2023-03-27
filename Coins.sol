// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

/// @title A ERC20 contract Coins
/// @author Harsh Laddha
/// @notice You can use this contract for basic coin exchange
contract Coins is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private _totalSupply;

    address private _deployer;

    mapping(address => uint256) private _balanceOf;
    mapping(address => mapping(address => uint256)) private _allowance;
    
    constructor (string memory name_ , string memory symbol_){
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
        _deployer = msg.sender;
        _balanceOf[msg.sender] = 1000;
    }

    function name() external view returns (string memory){
        return _name;
    }

    function symbol() external view returns (string memory){
        return _symbol;
    }

    function decimals() external view returns (uint8){
        return _decimals;
    }

    function totalSupply() external view returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address _owner) external view returns (uint256 balance){
        return _balanceOf[_owner];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(recipient != address(0), "transfer to the zero address");
        require(_balanceOf[msg.sender] >= amount, "Insufficient Balance");
           _balanceOf[msg.sender] -= amount;
            _balanceOf[recipient] += amount;
            emit Transfer(msg.sender, recipient, amount);
            return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success){
        _allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender , _spender , _value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256){
        return _allowance[owner][spender];
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success){
        require(_from != address(0), "transfer from 0 address");
        require(_to != address(0), "transfer to 0 address");
        require(allowance(_from , msg.sender) >= _value);
            uint change = allowance(_from , msg.sender) - _value;
            approve(msg.sender , change);
            _balanceOf[msg.sender] -= _value;
            _balanceOf[_to] += _value;
            emit Transfer(_from , _to , _value);
            return true;
        
    }

    function _mint(address minter , uint amount) internal {
        _totalSupply += amount;
        _balanceOf[minter] += amount;

        emit Transfer(address(0), minter, amount); 
    }

    function mint(address minter , uint amount) external {
        require(minter == _deployer , "not allowed to mint");

        _mint(minter , amount);
    }

    function burn(uint amount) external {
        require(_balanceOf[msg.sender] >= amount);
        _balanceOf[msg.sender] -= amount;
    }

}