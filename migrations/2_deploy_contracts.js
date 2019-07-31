var EducatorNetwork = artifacts.require("./EducatorNetwork.sol");

module.exports = function(deployer){
    deployer.deploy(EducatorNetwork);
};