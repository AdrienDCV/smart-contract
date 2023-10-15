const SimpleStorage = artifacts.require("Voting");

module.exports = function (deployer) {
  deployer.deploy(Voting);
};
