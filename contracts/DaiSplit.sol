pragma solidity ^0.4.25;

// import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/master/contracts/token/ERC20/ERC20.sol";

//ERC20 Contract goes here


contract DaiSplit {
  address owner;
  address[] members;
  address ERC20_ADDRESS;
  bool assetLocked; //tracks asset lock status of all members
  mapping(address => bool) member_AssetLock; //tracks asset lock status of each member
  uint public ALLOWANCE_RATE;

  mapping (string => address) member_Name_Address;
  mapping (address => string) member_Address_Name;
  
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

  function raiseExpenditure(uint _expenditureAmt) returns (bool _recordExpStatus) {
    
  }
}
