//@ts-ignore
import { require, console } from "@ora-io/cle-lib";
import { Bytes, Block, Account, BigInt } from "@ora-io/cle-lib";

const addr = Bytes.fromHexString('0x9ebEE9820BfC27775D0Ff87dBA8e94B5FD52d9F3')
const key = Bytes.fromHexString('0x0000000000000000000000000000000000000000000000000000000000000000')
const threshold = BigInt.fromI32(50)

export function handleBlocks(blocks: Block[]): Bytes {
  console.log("Entering handleBlocks...");
  let account: Account = blocks[0].account(addr);

  // check if the slot exists
  require(account.hasSlot(key) , "No slot found");

  let value:Bytes = account.storage(key);
 
  // check if the value is less than the threshold
  require(BigInt.fromBytes(value)<threshold, "requirement not met");
  
  // call aiClaim() on the desitination smart contract
  return Bytes.fromHexString("2b27b3da").padEnd(32);
}
