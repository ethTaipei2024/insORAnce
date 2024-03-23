# CLE uniswrapperice template

## Dev note

### setup the cle project dir:

- run `$ yarn`
- copy `.env-temp.txt` into `.env` and update the needed keys/api keys

### For running CLE (reference: https://github.com/ora-io/cle-cli?tab=readme-ov-file)

The args provided in the following command are just for reference, please check the above doc for the actual item to put at the position

#### compile

- `$ yarn cle compile ./`

#### execute

- `$ yarn cle exec 5541111 ./` 5541111 refers to the block ID, could check on etherscan to determin which blockID to run on

#### setup

- `$ yarn cle setup ./`

#### prove

`$ cle prove <blockId> <expectedStateStr> [root]` :

- `$ yarn cle prove 5542098 2b27b3da00000000000000000000000000000000000000000000000000000000`

#### upload image to ipfs

- `$ yarn cle upload`

#### publish (register)

`$ cle publish <ipfs_hash> [bounty_reward_per_trigger]`:

- `$ yarn cle publish QmcqBr71sqyY13eHDy6ZdXi2Yqht95bvgBUsgyNnKG3nvE 0.001`

## Usage CLI

> Note: Only `full` image will be processed by zkOracle node. `unsafe` (define `unsafe: true` in the `cle.yaml`) means the CLE is compiled locally and only contains partial computation (so that proving and executing will be faster).

The workflow of local CLE development must follow: `Develop` (code in /src) -> `Compile` (get compiled wasm image) -> `Execute` (get expected output) -> `Prove` (generate input and pre-test for actual proving in zkOracle) -> `Verify` (verify proof on-chain).

To upload and publish your CLE, you should `Upload` (upload code to IPFS), and then `Publish` (register CLE on onchain CLE Registry).

## Commonly used commands

- **compile**: `npx cle compile`
- **exec**: `npx cle exec <block id>`
- **prove**: ` npx cle prove <block id> <expected state> -i|-t|-p`
- ……

Read more: https://github.com/ora-io/cle-cli#cli
