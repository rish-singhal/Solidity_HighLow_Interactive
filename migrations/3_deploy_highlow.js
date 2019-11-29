var Game = artifacts.require("./HighLow.sol");

module.exports = function(deployer) {
  deployer.deploy(Game);
};
