pragma solidity ^0.4.16;

// import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
// import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/master/contracts/token/ERC20/ERC20.sol";

//ERC20 Contract goes here
/*
Implements EIP20 token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
.*/


// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md


contract EIP20Interface {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    // solhint-disable-next-line no-simple-event-func-name
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract EIP20 is EIP20Interface {

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX

    function EIP20(
    ) public {
        balances[msg.sender] = 1000000;               // Give the creator all initial tokens
        totalSupply = 1000000;                        // Update total supply
        name = "MAKER DAI";                                   // Set the name for display purposes
        decimals = 18;                            // Amount of decimals for display purposes
        symbol = "DAI";                               // Set the symbol for display purposes
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        // emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        // emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        // emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract DaiSplit {
  address owner;
  address[] members;
  address ERC20_ADDRESS;
  bool assetLocked; //tracks asset lock status of all members
  mapping(address => bool) member_AssetLock; //tracks asset lock status of each member
  uint public ALLOWANCE_RATE;

  mapping (string => address) member_Name_Address;
  mapping (address => string) member_Address_Name;

  mapping (address=>uint) debit; // IOUs
  mapping (address=>uint) credit; // UOMEs

  modifier isOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier assetsLocked(){
    require(member_AssetLock[members[0]]==member_AssetLock[members[1]]==member_AssetLock[members[2]]==member_AssetLock[members[3]]==member_AssetLock[members[4]]==true);
    _;
  }
  modifier isMember(){
    require(msg.sender == members[0]||msg.sender == members[1]||msg.sender == members[2]||msg.sender == members[4]);
    _;
  }    

  // Contract Creation & Invitation
  constructor (address _mem1, address _mem2, address _mem3, uint _defaultAllowance) {
    owner = msg.sender;
    members.push(owner);
    members.push(_mem1);
    members.push(_mem2);
    members.push(_mem3);
    setAllowanceRate(_defaultAllowance);
  } //TODO: Abstract the add members option as a function

  function setName(uint _memId,string _inputName) isOwner() {
    member_Address_Name[members[_memId]] = _inputName;
  }

  // Collateralize the ERC-20 assets for participation eligibility
  function lockAssets(uint64 _amount) returns (bool) {
    ERC20 erc20a = ERC20(ERC20_ADDRESS);
    erc20a.transfer(this, _amount);
    // erc20a.transferFrom(msg.sender, this, _amount);
    assetLocked = true; //Eligible
    return true;
  }

  // Set an allowance agreed upon off-chain, by friends
  function setAllowanceRate(uint _daiValue) isOwner() returns (uint _confirmRate) {
    ALLOWANCE_RATE = _daiValue;
    return ALLOWANCE_RATE;
  }

  function raiseExpenditure(uint _expenditureAmt, address _split1, address _split2, address _split3, address _split4, address _split5) returns (bool _recordExpStatus) {
    debit[members[0]] += _split1;
    debit[members[1]] += _split2;
    debit[members[2]] += _split3;
    debit[members[3]] += _split4;
    debit[members[4]] += _split5;

    credit[msg.sender] += _expenditureAmt;
  }

  function rePay(uint _repayAmount) returns (bool _repayStatus) {
    
  }

  function recoverAsset() {

  }
}
