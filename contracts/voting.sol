pragma solidity 0.4.24;

contract Voting {
    struct Split {
        uint id;
        uint voteCount;
        //TODO: structure of split
    }
    mapping(address => bool) public voters;
    mapping(uint => Split) public splits;
    uint public splitsCount;

    event votedEvent (
        uint indexed _splitId
    );

    constructor Voting () public {
        //TODO: add some splits for voting
    }

    function addSplits (string _name) private {
        splitsCount ++;
        splits[splitsCount] = Splits(splitsCount, 0); // create new split
    }

    function vote (uint _splitsId) public {
        require(!voters[msg.sender]);
        require(_splitsId > 0 && _splitsId <= splitssCount);
        voters[msg.sender] = true;
        splits[_splitsId].voteCount ++;
        votedEvent(_splitsId);
    }
}
