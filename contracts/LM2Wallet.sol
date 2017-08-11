pragma solidity ^0.4.11;

import './LordCoin.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract LM2Wallet is Ownable {
  using SafeMath for uint256;

  LordCoin public LC;
  address activeGames;

  event LCsRecievedForGameAccount(address indexed from, uint128 uuid, uint256 value);

  function LM2Wallet(address _lcAddr, address _agAddr) {
    LC = LordCoin(_lcAddr);
    activeGames = _agAddr;
  }

  function inGameCoins() internal constant returns (uint256) {
    return LC.balanceOf(this);
  }

  function playerToPlayer(uint256 _value) onlyOwner {
    assert(inGameCoins() >= _value);
    uint256 fee = _value.div(5);
    uint256 toBurn = fee.div(2);

    LC.burn(toBurn);
    LC.transfer(activeGames, fee - toBurn);
  }

  function playerToGame(uint256 _value) onlyOwner {
    assert(inGameCoins() >= _value);
    uint256 toBurn = _value.mul(9).div(10);
    
    if (LC.burn(toBurn)) {
      LC.transfer(activeGames, _value - toBurn);
    }
  }

  function transferToGameAccount(address _from, uint128 _uuid, uint256 _value) onlyOwner {
    require(LC.allowance(_from, this) >= _value);
    if (LC.transferFrom(_from, this, _value)) {
      LCsRecievedForGameAccount(_from, _uuid, _value);
    }
  }
}
