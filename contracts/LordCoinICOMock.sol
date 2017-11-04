pragma solidity 0.4.15;

import './LordCoinICO.sol';

contract LordCoinICOMock is LordCoinICO {
	uint256 private _now;

	function LordCoinICOMock (
        address _lcAddr,
        address _beneficiary,
        uint256 _priceETH,
        uint256 _priceLC,

        uint _startTime,
        uint _period1,
        uint _period2,
        uint _duration
    ) LordCoinICO (_lcAddr, _beneficiary, _priceETH, _priceLC, _startTime, _period1, _period2, _duration) public {
		_now = _startTime;
    }

    function getCurrentTime() internal constant returns(uint256) {
        return _now;
    }

    function changeTime(uint256 _newTime) external {
    	_now = _newTime;
    }
}