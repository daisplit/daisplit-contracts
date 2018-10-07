pragma solidity ^0.4.25;

// import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/master/contracts/token/ERC20/ERC20.sol";

//ERC20 Contract goes here


contract DaiSplit {

  address owner;
  string groupName;
  address[] members;
  address ERC20_ADDRESS;
  bool assetLocked; //tracks asset lock status of all members
  mapping(address => bool) member_AssetLock; //tracks asset lock status of each member
  uint public ALLOWANCE_RATE;

  mapping (string => address) member_Name_Address;
  mapping (address => string) member_Address_Name;

  mapping (address=>uint) debit; // IOUs
  mapping (address=>uint) credit; // UOMEs
  mapping(address => bool) public upvotes;



  modifier allApproved(){
      require(upvotes[members[0]]==upvotes[members[1]]==upvotes[members[2]]==upvotes[members[3]]==upvotes[members[4]]==true);
      _;
  }
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
  constructor (string _groupName, address _mem1, address _mem2, address _mem3, address _mem4, uint _defaultAllowance) {
    owner = msg.sender;
    groupName = _groupName;
    members.push(owner);
    members.push(_mem1);
    members.push(_mem2);
    members.push(_mem3);
    members.push(_mem4);
    setAllowanceRate(_defaultAllowance);
    emit GroupCreated(members[0], this);
    emit GroupCreated(members[1], this);
    emit GroupCreated(members[2], this);
    emit GroupCreated(members[3], this);
    emit GroupCreated(members[4], this);
  } //TODO: Abstract the add members option as a function

  // Set an allowance agreed upon off-chain, by friends
  function setAllowanceRate(uint _daiValue) isOwner() returns (uint _confirmRate) {
    ALLOWANCE_RATE = _daiValue;
    return ALLOWANCE_RATE;
  }
    // Collateralize the ERC-20 assets for participation eligibility
  function lockAssets() returns (bool) {
    ERC20 erc20a = ERC20(ERC20_ADDRESS);
    erc20a.transfer(this, ALLOWANCE_RATE);
    // erc20a.transferFrom(msg.sender, this, _amount);
    member_AssetLock[msg.sender] = true;
    return true;
  }

  function setName(uint _memId,string _inputName) isOwner() {
    member_Address_Name[members[_memId]] = _inputName;
  }

  function raiseExpenditure(uint _expenditureAmt, address _split1, address _split2, address _split3, address _split4, address _split5) assetsLocked() returns (bool _recordExpStatus) {
    debit[members[0]] += _split1;
    debit[members[1]] += _split2;
    debit[members[2]] += _split3;
    debit[members[3]] += _split4;
    debit[members[4]] += _split5;
    credit[msg.sender] += _expenditureAmt;
  }

  function approveInternal() returns (bool _approveStatus) {
    upvotes[members[0]] = true;
    upvotes[members[1]] = true;
    upvotes[members[2]] = true;
    upvotes[members[3]] = true;
    upvotes[members[4]] = true;
  }

  function resetApprove() returns (bool _resetApprvStatus) {
    upvotes[members[0]] = false;
    upvotes[members[1]] = false;
    upvotes[members[2]] = false;
    upvotes[members[4]] = false;
    upvotes[members[3]] = false;
  }

  /** //TODO: Repay to save the collateral
  function rePay(uint _repayAmount) returns (bool _repayStatus) {
    
  } **/

  /** //TODO: In case user not repaid the balance
  function recoverAsset() {

  } **/

  function approve() isMember(){
    upvotes[msg.sender] = true
  }

  function settleInContract() isOwner() {
    approveInternal();
    p
    resetApprove();
  }

  function payBackDAIs(address _payee) {
    ERC20 dai = ERC20(ERC20_ADDRESS);
    require(credit[_payee]>0);
    _amount = ALLOWANCE_RATE +credit[_payee] - debit[_payee];
    dai.transferFrom(this, _payee, _amount);
  }

  event GroupCreated(address _invitedUser, address _groupAddress);
}
