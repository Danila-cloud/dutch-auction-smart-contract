// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract AucEngine {
    address public owner; // adress which unfolded contract
    uint256 constant duration = 2 days; // default auction duration if it wasn't be set
    uint256 constant fee = 10;

    struct Auction {
        address payable seller;
        uint256 startingPrice;
        uint256 finalPrice;
        uint256 startAt;
        uint256 endsAt;
        uint256 discountRate;
        string item;
        bool isStoped;
    }

    Auction[] public auctions; // array with all auctions

    event AuctionCreated(
        uint256 index,
        string _item,
        uint256 _startingPrice,
        uint256 duration
    );

event AuctionEnded(uint index, uint finalPrice, address winner);

    constructor() {
        owner = msg.sender; // owner = adress which unfolder contract
    }

    function createAuction(
        uint256 _startingPrice,
        uint256 _discountRate,
        string calldata _item,
        uint256 _duration
    ) external {
        uint256 duration = _duration == 0 ? duration : _duration;

        require(
            _startingPrice >= _discountRate * duration,
            "incorrect starting price"
        ); // it is in order to price is not negative

        Auction memory newAuction = Auction({
            seller: payable(msg.sender),
            startingPrice: _startingPrice,
            finalPrice: _startingPrice,
            discountRate: _discountRate,
            startAt: block.timestamp,
            endsAt: block.timestamp + duration,
            item: _item,
            isStoped: false
        });

        auctions.push(newAuction); // push acrion to array with all auctions

        emit AuctionCreated(
            auctions.length - 1,
            _item,
            _startingPrice,
            duration
        );
    }

    function getPriceFor(uint256 index) public view returns (uint256) {
        Auction memory cAuction = auctions[index];

        require(!cAuction.isStoped, "Auction is already stopped!");  // check if auction not stopped yet

        uint256 elapsed = block.timestamp - cAuction.startAt;

        uint256 discount = cAuction.discountRate * elapsed;  // total discountRate

        return cAuction.startingPrice - discount;
    }

    function buy(uint256 index) external payable {
        Auction memory cAuction = auctions[index];

        require(!cAuction.isStoped, "Auction is already stopped!");  // exeptions
        require(block.timestamp < cAuction.endsAt, "Auctions is ended!");

        uint cPrice = getPriceFor(index);

        require(msg.value >= cPrice, "your bid is less than actual price");
        cAuction.isStoped = true;
        cAuction.finalPrice = cPrice;

        uint refund = msg.value - cPrice;  // calculate if user send value bigger than actual price
        if(refund > 0){
            payable(msg.sender).transfer(refund);  // refund
        }

        cAuction.seller.transfer(cPrice / 100 * 90);  // send money to seller
        emit AuctionEnded(index, cPrice, msg.sender);
    }
}
