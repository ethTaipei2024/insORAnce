//@ts-ignore
import { require, console } from "@ora-io/cle-lib";
import { Bytes, Block, Account, BigInt } from "@ora-io/cle-lib";

const addr = Bytes.fromHexString('0x9ebEE9820BfC27775D0Ff87dBA8e94B5FD52d9F3')
const key = Bytes.fromHexString('0x0000000000000000000000000000000000000000000000000000000000000000')
const waterline = BigInt.fromI32(1000)
const termId = BigInt.fromI32(1)

export function handleBlocks(blocks: Block[]): Bytes {
  console.log("Entering handleBlocks...");

  let account: Account = blocks[0].account(addr);

  // check if the slot exists
  require(account.hasSlot(key) , "No slot found");

  let value:Bytes = account.storage(key);
 
  // check if the value is less than the threshold
  require(BigInt.fromBytes(value) < waterline.div(5), "requirement not met");
  const percentage = (waterline.minus(BigInt.fromBytes(value))).times(BigInt.fromI32(100)).div(waterline);
  console.log("value: "+BigInt.fromBytes(value).toString())
  console.log("waterline - value: "+(waterline.minus(BigInt.fromBytes(value))).toString())
  console.log("calculated percentage: "+percentage.toString());
  
  const varTermId = Bytes.fromI32(termId.toI32()).padStart(32, 0);
  const varPercentage = Bytes.fromI32(percentage.toI32()).padStart(32, 0);
  const varBlockNumber = Bytes.fromI64(blocks[0].number).padStart(32, 0)
  
  // call aiClaim(bytes32, uint256) on the desitination smart contract
  return Bytes.fromByteArray(Bytes.fromHexString("1349613a").concat(varTermId).concat(varPercentage).concat(varBlockNumber));
}
