pragma solidity ^0.4.11;

import './LordCoin.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract LordCoinPreICO is Ownable {
    using SafeMath for uint256;

    string public name = "Lord Coin Pre-ICO";

    LordCoin public LC;
    address public beneficiary;

    uint256 public priceWEI;
    uint256 public priceLC;

    uint256 public weiRaised = 0;
    uint256 public investorCount = 0;

    uint public startTime;
    uint public endTime;

    bool public crowdsaleFinished = false;

    event GoalReached(uint amountRaised);
    event NewContribution(address indexed holder, uint256 tokenAmount, uint256 etherAmount);

    modifier onlyAfter(uint time) {
        require(now > time);
        _;
    }

    modifier onlyBefore(uint time) {
        require(now < time);
        _;
    }

    function AhooleeTokenPreSale(
        address _lcAddr,
        address _beneficiary,
        uint256 _priceWEI,
        uint256 _priceLC,

        uint _startTime,
        uint _duration
    ) {
        LC = LordCoin(_lcAddr);
        beneficiary = _beneficiary;
        priceWEI = _priceWEI;
        priceLC = _priceLC;

        startTime = _startTime;
        endTime = _startTime + _duration * 1 days;
    }

    function () payable {
        require(msg.value >= 0.01 * 1 ether);
        doPurchase(msg.sender, msg.value);
    }

    function withdraw() onlyOwner {
        beneficiary.transfer(collected);
        crowdsaleFinished = true;
    }

    function doPurchase(address _sender, uint256 _value) private onlyAfter(startTime) onlyBefore(endTime) {
        
        require(!crowdsaleFinished);

        uint256 lcCount = _value.mul(priceLC).div(priceWEI);

        require(LC.balanceOf(this) >= lcCount)

        if (LC.balanceOf(_sender) == 0) investorCount++;

        LC.transfer(_sender, lcCount);

        weiRaised = weiRaised.add(_value);

        NewContribution(_owner, lcCount, _value);

        if (LC.balanceOf(this) == 0) {
            GoalReached(weiRaised);
        }
    }
}