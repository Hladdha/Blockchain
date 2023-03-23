// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface IERC721 is IERC165 {
    function balanceOf(address owner) external view returns (uint balance);

    function ownerOf(uint tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint tokenId) external;

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes calldata data
    ) external;

    function transferFrom(address from, address to, uint tokenId) external;

    function approve(address to, uint tokenId) external;

    function getApproved(uint tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);

}
contract Assets is IERC721 {

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    mapping(uint => address) internal _ownerOf;

    mapping(address => uint) internal _balanceOf;

    mapping(uint => address) internal _approvals;

    /// mapping id to the no of coins
    mapping(uint => uint) internal _value;

    uint internal _id;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    function balanceOf(address owner) external view returns (uint balance){
        require(owner != address(0), "zero address");
        return _balanceOf[owner];
    }

    function ownerOf(uint tokenId) external view returns (address owner){
        owner  = _ownerOf[tokenId];
        require(owner != address(0) , "NFTs assigned to zero address");
        return owner;
    }

    
    function transferFrom(address _from, address _to, uint256 _tokenId) external {
        require(_from == _ownerOf[_tokenId] , "not the current owner");
        require(_to != address(0) , "recipent is a Zero address");

        require(message.sender == _approvals[tokenId] || isApprovedForAll(_from , message.sender) , "Is not approved to transfer")

        _ownerOf[_tokenId] = _to;
        _balanceOf[_from] -= 1;
        _balanceOf[_to] += 1;
        
        _approvals[_tokenId] = address(0);

        emit Transfer(_from , _to , _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external {
        require(message.sender == _ownerOf[_tokenId] , "not the current owner");
        _approvals[_tokenId] = _approved;
    }

    function getApproved(uint tokenId) external view returns (address operator) {
        if(_approvals[tokenId]){
            return _approvals[tokenId];
        }
        return address(0);
    }

    function setApprovalForAll(address operator, bool _approved) external{
        isApprovedForAll[msg.sender][operator] = _approved;
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool){
        return isApprovedForAll[msg.sender][operator];
    }

    function safeTransferFrom(address from, address to, uint tokenId) external{
        transferFrom(from , to , tokenId);
        
    ///  Throws if When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    }

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes calldata data
    ) external{
    transferFrom(from , to , tokenId);
    ///  Throws if When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    }

    /// mint function takes the asset value (in Terms of coin) from the user
    function mint() external {
        id++;
        _ownerOf[id] = msg.sender;
    }

    function setAssetValue(uint value , uint _tokenId) external {
        require(_ownerOf[id] == msg.sender , "You are not the owner");

        _value[_tokenId] = value;
    }

    function swap(uint _tokenId , address owner) external {
        require(_value[_tokenId] , "Not tradeable");

        transferFrom(owner , msg.sender , _tokenId);
    }
}