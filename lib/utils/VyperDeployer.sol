// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;
interface VM {
    function ffi(string[] calldata) external returns (bytes memory);
    function broadcast() external;
}

library VyperDeployer {
    address constant HEVM_ADDRESS =
        address(bytes20(uint160(uint256(keccak256("hevm cheat code")))));

    VM constant vm = VM(HEVM_ADDRESS);

    /// @notice Compiles a Vyper contract and returns the address that the contract was deployed to
    /// @param fileName The file name of the Vyper contract. 
    ///                 For example, the file name for "SimpleStore.vy" is "SimpleStore".
    /// @param broadcast - Whether or not to broadcast the transaction.
    /// @return deployedAddress The address that the contract was deployed to.
    function deploy(string memory fileName, bool broadcast) public returns (address) {
        ///@notice create a list of strings with the commands necessary to compile Vyper contracts
        string[] memory cmds = new string[](2);
        cmds[0] = "vyper";
        cmds[1] = string.concat("vyper_contracts/", fileName, ".vy");

        ///@notice compile the Vyper contract and return the bytecode
        bytes memory bytecode = vm.ffi(cmds);

        ///@notice deploy the bytecode with the create instruction
        address deployedAddress;
        if (broadcast) vm.broadcast();
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        ///@notice check that the deployment was successful
        require(
            deployedAddress != address(0),
            "VyperDeployer could not deploy contract"
        );

        ///@notice return the address that the contract was deployed to
        return deployedAddress;
    }

    /// @notice Compiles a Vyper contract with constructor arguments and returns the address  
    ///         that the contract was deployed to.
    /// @param fileName The file name of the Vyper contract. 
    ///                 For example, the file name for "SimpleStore.vy" is "SimpleStore".
    /// @param args The abi-encoded arguments for the constructor.
    /// @param broadcast Whether or not to broadcast the transaction.
    /// @return deployedAddress The address that the contract was deployed to.
    function deploy(string memory fileName, bytes calldata args, bool broadcast)
        public
        returns (address)
    {
        ///@notice create a list of strings with the commands necessary to compile Vyper contracts
        string[] memory cmds = new string[](2);
        cmds[0] = "vyper";
        cmds[1] = string.concat("vyper_contracts/", fileName, ".vy");

        ///@notice compile the Vyper contract and return the bytecode
        bytes memory _bytecode = vm.ffi(cmds);

        //add args to the deployment bytecode
        bytes memory bytecode = abi.encodePacked(_bytecode, args);

        ///@notice deploy the bytecode with the create instruction
        address deployedAddress;
        if (broadcast) vm.broadcast();
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        ///@notice check that the deployment was successful
        require(
            deployedAddress != address(0),
            "VyperDeployer could not deploy contract"
        );

        ///@notice return the address that the contract was deployed to
        return deployedAddress;
    }
}