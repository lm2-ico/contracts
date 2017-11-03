pragma solidity 0.4.15;

import './LordCoin.sol';
import 'zeppelin-solidity/contracts/ownership/HasNoEther.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract LordCoinLock is HasNoEther {
    using SafeMath for uint256;

    LordCoin public LC;
    uint public startTime;
    uint public endTime1;
    uint public endTime2;
    uint256 public tranche;

    modifier onlyAfter(uint time) {
        require(getCurrentTime() > time);
        _;
    }

    function LordCoinLock (
        address _lcAddr,
        uint _startTime,
        uint _duration,
        uint256 _tranche
    ) HasNoEther() public {
        LC = LordCoin(_lcAddr);

        startTime = _startTime;
        endTime1 = _startTime + _duration * 1 days;
        endTime2 = _startTime + 2 * _duration * 1 days;

        tranche = _tranche;
    }

    function withdraw1(uint256 _value) external onlyOwner onlyAfter(endTime1) {
        require(_value <= tranche);
        LC.transfer(owner, _value);
        tranche = tranche.sub(_value);
    }

    function withdraw2(uint256 _value) external onlyOwner onlyAfter(endTime2) {
        LC.transfer(owner, _value);
    }

    function lcBalance() external constant returns(uint256) {
        return LC.balanceOf(this);
    }

    function getCurrentTime() internal constant returns(uint256) {
        return now;
    }
}