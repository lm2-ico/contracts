pragma solidity ^0.4.11;

import './LordCoin.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract LordCoinICO is Ownable {
    using SafeMath for uint256;

    string public name = "Lord Coin ICO";

    LordCoin public LC;
    address public beneficiary;

    uint256 public priceETH;
    uint256 public priceLC;

    uint256 public weiRaised = 0;
    uint256 public investorCount = 0;

    uint public startTime;
    uint public endTime;
    uint public time1;
    uint public time2;

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

    function LordCoinICO (
        address _lcAddr,
        address _beneficiary,
        uint256 _priceETH,
        uint256 _priceLC,

        uint _startTime,
        uint _period1,
        uint _period2,
        uint _duration
    ) {
        LC = LordCoin(_lcAddr);
        beneficiary = _beneficiary;
        priceETH = _priceETH;
        priceLC = _priceLC;

        startTime = _startTime;
        time1 = startTime + _period1 * 1 hours;
        time2 = time1 + _period2 * 1 hours;
        endTime = _startTime + _duration * 1 days;
    }

    function () payable {
        require(msg.value >= 0.01 * 1 ether);
        doPurchase(msg.sender, msg.value);
    }

    function withdraw(uint256 _value) onlyOwner {
        beneficiary.transfer(_value);
    }

    function finishCrowdsale() onlyOwner {
        LC.transfer(beneficiary, LC.balanceOf(this));
        crowdsaleFinished = true;
    }

    function doPurchase(address _sender, uint256 _value) private onlyAfter(startTime) onlyBefore(endTime) {
        
        require(!crowdsaleFinished);

        uint256 lcCount = _value.mul(priceLC).div(priceETH);

        if (now > time1 && now <= time2 && _value < 500 * 1 ether) {
            lcCount = lcCount.mul(100).div(110);
        }

        if (now > time2 && _value < 500 * 1 ether) {
            lcCount = lcCount.mul(100).div(125);
        }

        require(LC.balanceOf(this) >= lcCount);

        if (LC.balanceOf(_sender) == 0) investorCount++;

        LC.transfer(_sender, lcCount);

        weiRaised = weiRaised.add(_value);

        NewContribution(_sender, lcCount, _value);

        if (LC.balanceOf(this) == 0) {
            GoalReached(weiRaised);
        }
    }
}