pragma solidity 0.4.15;

import './LordCoinLock.sol';

contract LordCoinLockMock is LordCoinLock {
	uint256 private _now;

	function LordCoinLockMock (
        address _lcAddr,
        uint _startTime,
        uint _duration,
        uint256 _tranche
    ) LordCoinLock (_lcAddr, _startTime, _duration, _tranche) public {
		_now = _startTime;
    }

    function getCurrentTime() internal constant returns(uint256) {
        return _now;
    }

    function changeTime(uint256 _newTime) external {
    	_now = _newTime;
    }
}