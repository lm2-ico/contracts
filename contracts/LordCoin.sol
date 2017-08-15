pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract LordCoin is StandardToken {
  using SafeMath for uint256;

  string public name = "Lord Coin";
  string public symbol = "LC";
  uint256 public decimals = 18;
  uint256 public INITIAL_SUPPLY = 20000000 * 1 ether;

  event Burn(address indexed from, uint256 value);

  function LordCoin() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }

  function burn(uint256 _value) returns (bool success) {
    require(balances[msg.sender] >= _value);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(msg.sender, _value);
    return true;
  }
}
