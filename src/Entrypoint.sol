// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @notice Entrypoint ERC-1967 proxy and storage contract for the UUPS based architecture
 * @author @radeksvarz
 * @author Adapted from OpenZeppelin
 * @dev Enables to call initialization function to avoid frontrunning
 */
contract Entrypoint {
    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev `keccak256(bytes("Upgraded(address)"))`
     */
    uint256 private constant _UPGRADED_EVENT_SIGNATURE =
        0xbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b;

    /**
     * @dev The `implementation` of the proxy is invalid.
     */
    error ERC1967InvalidImplementation(address implementation);

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1.
     */
    // solhint-disable-next-line private-vars-leading-underscore
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `implementation`.
     *
     * If `data` is nonempty, it's used as data in a delegate call to `implementation`. This will typically be an
     * encoded function call, and allows initializing the storage of the proxy like a Solidity constructor.
     *
     * Emits an {IERC1967-Upgraded} event.
     *
     */
    constructor(address implementation, bytes memory data) payable {
        assembly {
            // Revert when implementation address does not contain code
            if iszero(extcodesize(implementation)) {
                // revert ERC1967InvalidImplementation(implementation);
                mstore(0x00, 0x4c9c8ce3)
                mstore(0x20, implementation)
                revert(0x1c, 0x24)
            }

            // Store a new address in the ERC-1967 implementation slot
            sstore(_IMPLEMENTATION_SLOT, implementation)

            // emit {Upgraded} event
            log2(0, 0, _UPGRADED_EVENT_SIGNATURE, implementation)

            // Execute initialization call when function calldata are provided
            let data_size := mload(data)
            if data_size {
                // Call the implementation.
                // out and outsize are 0 because we don't know the size yet.
                let result := delegatecall(gas(), implementation, add(32, data), data_size, 0, 0)

                // delegatecall returns 0 on error.
                if iszero(result) {
                    // Copy the returned error data and bubble up revert
                    returndatacopy(0, 0, returndatasize())
                    revert(0, returndatasize())
                }
            }

            // @dev: No need to restore memory pointers, as the rest of the constructor just returns the runtime
            // bytecode
        }
    }

    /**
     * @dev Fallback function that delegates calls to the current implementation address.
     * Will run if no other function in the contract matches the call data.
     * This function will return directly to the external caller.
     */
    fallback() external payable {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), sload(_IMPLEMENTATION_SLOT), 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}
