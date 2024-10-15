// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Initializable} from "@oz-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@oz-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@oz-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract Implementation is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    /// @custom:storage-location erc7201:example.storage.Implementation
    // @dev using the storage location as defined in OZ 5.x
    struct ImplementationStorage {
        //
        // SLOT 00
        /**
         * @notice Example value storage
         */
        uint256 _value;
    }

    /**
     * @dev Namespace label in the storage layout report (empty space).
     */
    // solhint-disable-next-line private-vars-leading-underscore, var-name-mixedcase
    ImplementationStorage private ERC7201_example_implementation_storage;

    /**
     * @dev custom storage location
     */
    // solhint-disable-next-line private-vars-leading-underscore
    function $ImplementationStorage() internal pure returns (ImplementationStorage storage $) {
        assembly {
            // keccak256(abi.encode(uint256(keccak256("example.storage.Implementation")) - 1)) & ~bytes32(uint256(0xff))
            $.slot := 0x4b824c110a202917532f3ca369de7f112d48acedcc5d7dcb120530d67fc54800
        }
    }

    event ValueChanged(uint256 newValue);

    error CustomError(uint256 value);

    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    /**
     * @notice Get the value
     */
    function value() public view virtual returns (uint256) {
        return $ImplementationStorage()._value;
    }

    /**
     * @notice Set the value
     */
    function setValue(uint256 newValue) public {
        $ImplementationStorage()._value = newValue;
        emit ValueChanged(newValue);
    }

    /**
     * @notice Example revert
     */
    function revertWithError() public view {
        revert CustomError(value());
    }

    /**
     *  @notice Authorisation check of the upgrade mechanisms
     */
    function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner {}
}
