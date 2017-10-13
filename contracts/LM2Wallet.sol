pragma solidity 0.4.17;

import './LordCoin.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract LM2Wallet is Ownable {
  using SafeMath for uint256;

  LordCoin public lc;
  address public activeGames;

  event LCsRecievedForGameAccount(address indexed from, uint128 uuid, uint256 value);

  function LM2Wallet(address _lcAddr, address _agAddr) {
    lc = LordCoin(_lcAddr);
    activeGames = _agAddr;
  }

  function inGameCoins() internal constant returns (uint256) {
    return lc.balanceOf(this);
  }

  function playerToPlayer(uint256 _value) external public onlyOwner {
    assert(inGameCoins() >= _value);
    uint256 fee = _value.div(5);
    uint256 toBurn = fee.div(2);

    lc.burn(toBurn);
    lc.transfer(activeGames, fee - toBurn);
  }

  function playerToGame(uint256 _value) external public  onlyOwner {
    assert(inGameCoins() >= _value);
    uint256 toBurnTokens = _value.mul(9).div(10);
    
    if (lc.burn(toBurnTokens)) {
      lc.transfer(activeGames, _value - toBurnTokens);
    }
  }

  function transferToGameAccount(address _from, uint128 _uuid, uint256 _value) external public  onlyOwner {
    require(lc.allowance(_from, this) >= _value);
    if (lc.transferFrom(_from, this, _value)) {
      LCsRecievedForGameAccount(_from, _uuid, _value);
    }
  }
}
