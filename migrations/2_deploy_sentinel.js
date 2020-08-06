const Sentinel = artifacts.require("Sentinel");

module.exports = function(deployer) {
  deployer.deploy(Sentinel, '0xBeb71662FF9c08aFeF3866f85A6591D4aeBE6e4E');
};
