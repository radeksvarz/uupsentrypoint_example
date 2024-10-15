# Pure entrypoint ERC-1967 proxy for UUPS upgradeable contracts - deployment example

Example of https://github.com/radeksvarz/erc1967uupsentrypoint - the lightweight ERC-1967 proxy implementation.

Having 2 step deploy script using Create-X CREATE3 https://github.com/radeksvarz/createx-forge for deterministic entrypoint proxy address immune to solc / mbor / source code comment changes in time.

Deployed on Sepolia: https://eth-sepolia.blockscout.com/address/0xC0bf4d3F67B0B516930B28A90fe4022F20bEbE96?tab=contract

Beware of setting up proper `--sender` when invoking `forge script`, otherwise deployed address does not match.

Example `Implementation` uses ERC-7201 storage to mitigate upgrade storage collision issues / hacks.

```
 ┌──────────────────────┐
 │ Entrypoint           │
 ├──────────────────────┤
 │                      │
 │ (ERC1967 proxy)      │
 │                      │
 │ Immune to OZ changes │
 │ in the future        │
 │                      │
 └─────────┬────────────┘
           │
           │ delegatecall
           │
 ┌─────────▼─────────────────┐
 │ Implementation            │
 ├───────────────────────────┤
 │ (UUPS based contract)     │
 │                           │
 │ w/ safer ERC-7201 storage │
 │ for future upgrades       │
 │                           │
 └───────────────────────────┘
```

# License MIT
