pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/HighLow.sol";

contract TestHighLow {
 // The address of the adoption contract to be tested
HighLow highlow = HighLow(DeployedAddresses.HighLow());

 uint pdx = 0;
 uint x = 0;
 uint y = 0;
 uint ex = 0;
 uint zz = 1;
 string xx = "hi";
// Testing the adopt() function
function testiniState() public {
  string memory returnedId = highlow.stateOfGame();
  Assert.equal(returnedId, xx, "Working Fine.");
}

function testgamestate() public {
  string memory returnedId = highlow.setNumOfPlayers(1);
  Assert.equal(returnedId, xx, "Working Fine.");
}

function testiniState2() public {
  string memory returnedId = highlow.stateOfGame();
  Assert.equal(returnedId, xx, "Working Fine.");
}

function testiniState3() public {
 uint returnedId = highlow.showin();
  Assert.equal(returnedId, 10, "Working Fine.");
}

}

