pragma solidity >= 0.8.1;

contract Subasta{

    address payable public beneficiary;
    uint public auctionEndTime;

    //estado actual de la subasta
    address public highestBidder;
    uint public highestbid;
    bool ended;

    mapping(address => uint) pendingReturns;

    event highestBidIncreased(address bidder, uint amount);
    event auctionEnded(address winner, uint amount);

    constructor(uint _biddingTime, address payable _beneficiary){
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    // poder apostar en la subasta 
    function bid() public payable{
        if(block.timestamp > auctionEndTime) revert('the auction has ended!');
        if(msg.value <= highestbid) revert('Sorry, the bid is not high enough!');

        if(highestbid != 0){
            pendingReturns[highestBidder] += highestbid;
        }

        highestBidder = msg.sender;
        highestbid = msg.value;
        emit highestBidIncreased(msg.sender, msg.value);
    }

    // regresar el dinero a las personas que no ganaron
    function withdraw() public payable returns(bool){
        uint amount = pendingReturns[msg.sender];
        if(amount > 0) {
            pendingReturns[msg.sender] = 0;
        }

        if(!payable(msg.sender).send(amount)) {
            pendingReturns[msg.sender] = amount;
        }
        return true;
    }


    function auctionEnd() public{
        if(block.timestamp < auctionEndTime) revert('the auction has not ended yet!');
        if(ended) revert('the auction is already over!');

        ended = true;
        emit auctionEnded(highestBidder, highestbid);
        beneficiary.transfer(highestbid);
    }

}