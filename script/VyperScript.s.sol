pragma solidity ^0.8.15;

import "forge-std/Script.sol";

contract VyperScript is Script {

    /// @notice Compiles a Vyper contract with constructor arguments and returns the address  
    ///         that the contract was deployed to.
    /// @param fileName The file name of the Vyper contract. 
    ///                 For example, the file name for "SimpleStore.vy" is "SimpleStore".
    /// @param args The abi-encoded arguments for the constructor.
    /// @param broadcast Whether or not to broadcast the transaction.
    /// @return deployedAddress The address that the contract was deployed to.
    function deploy(string memory fileName, bytes memory args, bool broadcast)
        public
        returns (address)
    {
        // create a list of strings with the commands necessary to compile Vyper contracts
        string[] memory cmds = new string[](2);
        cmds[0] = "vyper";
        cmds[1] = string.concat("src/", fileName, ".vy");

        // compile the Vyper contract and return the bytecode
        bytes memory _bytecode = vm.ffi(cmds);

        // add args to the deployment bytecode
        bytes memory bytecode = abi.encodePacked(_bytecode, args);

        // deploy the bytecode with the create instruction
        address deployedAddress;
        if (broadcast) vm.broadcast();
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        // check that the deployment was successful
        require(
            deployedAddress != address(0),
            "VyperDeployer could not deploy contract"
        );

        // return the address that the contract was deployed to
        return deployedAddress;
    }
}