# Pure entrypoint ERC-1967 proxy for UUPS upgradeable contracts - deployment example

Example of https://github.com/radeksvarz/erc1967uupsentrypoint

Deployed on Sepolia: https://eth-sepolia.blockscout.com/address/0xC0bf4d3F67B0B516930B28A90fe4022F20bEbE96?tab=contract

Uses Create-X CREATE3 deployment script to ensure Entrypoint is deployed to the same address among chains when compiler output changes in time. Beware of setting up proper `--sender` when invoking `forge script`, otherwise deployed address does not match.

Example implementation uses ERC-7201 storage to mitigate upgrade storage issues.

```
 ┌──────────────────┐
 │ Entrypoint       │
 ├──────────────────┤
 │                  │
 │ (ERC1967 proxy)  │
 │                  │
 └─────────┬────────┘
           │
           │ delegatecall
           │
 ┌─────────▼──────────────┐
 │ Implementation         │
 │                        │
 │ (UUPS based contract)  │
 │                        │
 └────────────────────────┘
```
