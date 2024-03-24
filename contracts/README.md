## InsORAnce contract

## DEV note
- AI Oracle (Sepolia): `0x0A0f4321214BB6C7811dD8a71cF587bdaF03f0A0`
- Dummy testing smart contract: `0xc9D7379285FA337D8Cb6586Aa0f3b4957b3F9b54`
- InsORAnce smart contract (v2): `0x9Fe737c0818a64Fc9b60D01bA2f1F8DC63C826Dd`/`0x4527e650706b51269c7f9a73223d2420b4a6cffc`
- InsORAnce smart contract (v3): `0x84c5b441596bb3a7f64b7e6b1e47928fccdd82ce`
- CLE contract (v2): `0xebf8b8c3dfd9bdfe9700a2de90f7c226a7ce8ce5`
- CLE contract (v3): `0xe8f6be532d821a447b5f13401115c1775185b86a`
- Prompt contract: `0xD8102C386CBA55207Aa1C0399E926d708fb81212`


**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```