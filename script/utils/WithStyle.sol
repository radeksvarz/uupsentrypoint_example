// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {VmSafe} from "forge-std/Vm.sol";

/**
 * @title Sript utility for coloured strings
 * @notice Based on https://github.com/foundry-rs/forge-std/blob/master/src/StdStyle.sol
 * @dev To be inherited by the deployment script
 */
abstract contract WithStyle {
    VmSafe private constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));

    string constant RED = "\u001b[91m";
    string constant GREEN = "\u001b[92m";

    string constant YELLOW = "\u001b[93m";
    string constant BLUE = "\u001b[94m";
    string constant MAGENTA = "\u001b[95m";
    string constant CYAN = "\u001b[96m";

    string constant BOLD = "\u001b[1m";
    string constant DIM = "\u001b[2m";
    string constant ITALIC = "\u001b[3m";
    string constant UNDERLINE = "\u001b[4m";
    string constant INVERSE = "\u001b[7m";
    string constant RESETCOLOR = "\u001b[0m";

    string constant GREENCHECK = "\u001b[92m\u2714";

    function red(string memory _str) internal pure returns (string memory) {
        return string(abi.encodePacked(RED, _str, RESETCOLOR));
    }

    function red(string memory _str, address _addr) internal pure returns (string memory) {
        return string(abi.encodePacked(RED, _str, vm.toString(_addr), RESETCOLOR));
    }

    function red(string memory _str0, address _addr0, string memory _str1, address _addr1)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(RED, _str0, vm.toString(_addr0), _str1, vm.toString(_addr1), RESETCOLOR));
    }

    function green(string memory _str) internal pure returns (string memory) {
        return string(abi.encodePacked(GREEN, _str, RESETCOLOR));
    }

    function green(string memory _str, address _addr) internal pure returns (string memory) {
        return string(abi.encodePacked(GREEN, _str, vm.toString(_addr), RESETCOLOR));
    }

    function greencheck(string memory _str) internal pure returns (string memory) {
        return string(abi.encodePacked(GREENCHECK, " ", _str, RESETCOLOR));
    }

    function greencheck(string memory _str, address _addr) internal pure returns (string memory) {
        return string(abi.encodePacked(GREENCHECK, " ", _str, vm.toString(_addr), RESETCOLOR));
    }
}
