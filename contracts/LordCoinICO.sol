pragma solidity 0.4.15;

import './LordCoin.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract LordCoinICO is Pausable {
    using SafeMath for uint256;

    string public constant name = "Lord Coin ICO";

    LordCoin public LC;
    address public beneficiary;

    uint256 public priceETH;
    uint256 public priceLC;

    uint256 public weiRaised = 0;
    uint256 public investorCount = 0;
    uint256 public lcSold = 0;

    uint public startTime;
    uint public endTime;
    uint public time1;
    uint public time2;

    uint public constant period2Numerator = 110;
    uint public constant period2Denominator = 100;
    uint public constant period3Numerator = 125;
    uint public constant period3Denominator = 100; 

    uint256 public constant premiumValue = 500 * 1 ether;

    bool public crowdsaleFinished = false;

    event GoalReached(uint256 amountRaised);
    event NewContribution(address indexed holder, uint256 tokenAmount, uint256 etherAmount);

    modifier onlyAfter(uint time) {
        require(getCurrentTime() > time);
        _;
    }

    modifier onlyBefore(uint time) {
        require(getCurrentTime() < time);
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
    ) public {
        LC = LordCoin(_lcAddr);
        beneficiary = _beneficiary;
        priceETH = _priceETH;
        priceLC = _priceLC;

        startTime = _startTime;
        time1 = startTime + _period1 * 1 hours;
        time2 = time1 + _period2 * 1 hours;
        endTime = _startTime + _duration * 1 days;
    }

    function () external payable whenNotPaused {
        require(msg.value >= 0.01 * 1 ether);
        doPurchase();
    }

    function withdraw(uint256 _value) external onlyOwner {
        beneficiary.transfer(_value);
    }

    function finishCrowdsale() external onlyOwner {
        LC.transfer(beneficiary, LC.balanceOf(this));
        crowdsaleFinished = true;
    }

    function doPurchase() private onlyAfter(startTime) onlyBefore(endTime) {
        require(!crowdsaleFinished);
        require(msg.sender != address(0));

        uint256 lcCount = msg.value.mul(priceLC).div(priceETH);

        if (getCurrentTime() > time1 && getCurrentTime() <= time2 && msg.value < premiumValue) {
            lcCount = lcCount.mul(period2Denominator).div(period2Numerator);
        }

        if (getCurrentTime() > time2 && msg.value < premiumValue) {
            lcCount = lcCount.mul(period3Denominator).div(period3Numerator);
        }

        uint256 _wei = msg.value;

        if (LC.balanceOf(this) < lcCount) {
          uint256 expectingLCCount = lcCount;
          lcCount = LC.balanceOf(this);
          _wei = msg.value.mul(lcCount).div(expectingLCCount);
          msg.sender.transfer(msg.value.sub(_wei));
        }

        transferLCs(msg.sender, _wei, lcCount);
    }

    function transferLCs(address _sender, uint256 _wei, uint256 _lcCount) internal {

        if (LC.balanceOf(_sender) == 0) investorCount++;

        LC.transfer(_sender, _lcCount);

        lcSold = lcSold.add(_lcCount);
        weiRaised = weiRaised.add(_wei);

        NewContribution(_sender, _lcCount, _wei);

        if (LC.balanceOf(this) == 0) {
            GoalReached(weiRaised);
        }

    }

    function manualSell(address _sender, uint256 _value) external onlyOwner {
        transferLCs(_sender, 0, _value);
    }



    function getCurrentTime() internal constant returns(uint256) {
        return now;
    }
}