// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script, console2} from "forge-std/Script.sol";
import {CreateXScript} from "createx-forge/script/CreateXScript.sol";

import {WithStyle} from "./utils/WithStyle.sol";

import {Entrypoint} from "src/Entrypoint.sol";
import {Implementation} from "src/Implementation.sol";

/**
 * @title Deploy upgradeable contracts
 * @notice Whole set is deployed within the `run` function deterministicaly using CREATE2 and CREATE3 approach.
 * @dev Via precalculated addresses to avoid cross reference transaction if such case is needed
 * @dev Define smoke checks below
 *
 *  ┌──────────────────┐
 *  │ Entrypoint       │
 *  ├──────────────────┤
 *  │                  │
 *  │ (ERC1967 proxy)  │
 *  │                  │
 *  └─────────┬────────┘
 *            │
 *            │ delegatecall
 *            │
 *  ┌─────────▼──────────────┐
 *  │ Implementation         │
 *  │                        │
 *  │ (UUPS based contract)  │
 *  │                        │
 *  └────────────────────────┘
 */
contract Deploy is Script, CreateXScript, WithStyle {
    // solhint-disable-next-line no-empty-blocks
    function setUp() public withCreateX {}

    function run() public {
        vm.startBroadcast();

        // Beware of setting up proper `--sender` when invoking `forge script`, otherwise deployed address does not match
        address deployer = msg.sender;
        console2.log("Deployer:", deployer);

        // solhint-disable-next-line var-name-mixedcase
        address ContractOwner = vm.envAddress("CONTRACT_OWNER");
        console2.log("Contract Owner: ", ContractOwner);

        //
        // Implementation deployment
        //
        bytes32 implSalt = keccak256(abi.encodePacked("Implementation Example", deployer));

        address implAddress = vm.computeCreate2Address(implSalt, hashInitCode(type(Implementation).creationCode));

        console2.log("Expected impl address:", implAddress);

        bytes32 extCodeHash = address(implAddress).codehash;

        Implementation implementation;

        if ((extCodeHash != 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470) && (extCodeHash != 0)) {
            console2.log(red("Already some code on the implementation contract address:", implAddress));
            implementation = Implementation(implAddress);
        } else {
            implementation = new Implementation{salt: implSalt}();
            console2.log(greencheck("Implementation deployed address:", address(implementation)));
        }

        require(
            implAddress == address(implementation), red("Implementation computed and deployed address do not match!")
        );

        //
        // Entrypoint deployment
        //
        bytes32 salt = bytes32(abi.encodePacked(deployer, hex"00", bytes11("Example")));
        address computedAddress = computeCreate3Address(salt, deployer);

        console2.log("Entrypoint computed contract address:", computedAddress);

        bytes32 proxyExtCodeHash = address(computedAddress).codehash;

        if (
            (proxyExtCodeHash != 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470)
                && (proxyExtCodeHash != 0)
        ) {
            revert(red("Already some code on the entrypoint contract address:", computedAddress));
        }

        bytes memory initializeData = abi.encodeWithSignature("initialize(address)", ContractOwner);

        address entrypoint =
            create3(salt, abi.encodePacked(type(Entrypoint).creationCode, abi.encode(implementation, initializeData)));

        console2.log(greencheck("Entrypoint deployed contract address:", entrypoint));

        require(computedAddress == entrypoint, red("Computed and deployed entrypoint address do not match! Check sender arg."));

        // For forge verify-contract --constructor-args
        console2.log("--constructor-args ", vm.toString(abi.encode(implementation, initializeData)));

        smokeChecks(computedAddress, ContractOwner);

        console2.log(greencheck("-------- Smoke checks passed --------\n"));

        vm.stopBroadcast();
    }

    /**
     * Smoke checks
     */
    function smokeChecks(address _entrypointAddress, address desiredOwner) public view {
        address owner = Implementation(_entrypointAddress).owner();
        require(owner == desiredOwner, red("BSOD: Ownership's gone rogue! ", owner));
    }
}
