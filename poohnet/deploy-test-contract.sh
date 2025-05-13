#!/bin/sh

source .env

if [ -z "$1" ]; then
	echo "Usage: $0 <json_rpc>"
	exit 1
fi

if [[ "$1" == "localnet" ]]; then
	JSON_RPC=$LOCALNET_RPC_URL
elif [[ "$1" == "devnet" ]]; then
	JSON_RPC=$DEVNET_RPC_URL
elif [[ "$1" == "marigold" ]]; then
	JSON_RPC=$MARIGOLD_RPC_URL
else
	echo "$1 is not a valid network"
	exit 1
fi

echo "Sending 1 ETH to temporary deployer"
AMOUNT="1.0"
cast send "$MY_ADDRESS" \
  --value "$(cast to-wei $AMOUNT eth)" \
  --private-key "$ADMIN_KEY" \
  --rpc-url "$JSON_RPC"

# deploy our contract
# contract: pragma solidity 0.5.8; contract Apple {function banana() external pure returns (uint8) {return 42;}}
BYTECODE="6080604052348015600f57600080fd5b5060848061001e6000396000f3fe6080604052348015600f57600080fd5b506004361060285760003560e01c8063c3cafc6f14602d575b600080fd5b6033604f565b604051808260ff1660ff16815260200191505060405180910390f35b6000602a90509056fea165627a7a72305820ab7651cb86b8c1487590004c2444f26ae30077a6b96c6bc62dda37f1328539250029"
DEPLOYER="4e59b44847b379578588920cA78FbF26c0B4956C"
SALT_HEX="$(cast --to-bytes32 0 | sed 's/^0x//')" 

echo "SALT_HEX: $SALT_HEX"

# 1) Compute the keccak256 of the init code (the contract bytecode)
CODE_HASH=$(cast keccak "0x$BYTECODE" | sed 's/^0x//')

# 2) Build a single hex string without 0x
#    "ff"   + deployer (no 0x)    + SALT_HEX    + CODE_HASH
DATA_NO_0X="ff$DEPLOYER$SALT_HEX$CODE_HASH"

# 3) Now run cast keccak on that single combined string
FULL_HASH=$(cast keccak "0x$DATA_NO_0X")

# 4) The CREATE2 address is the last 20 bytes
MY_CONTRACT_ADDRESS="0x${FULL_HASH:26}"

echo "MY_CONTRACT_ADDRESS=$MY_CONTRACT_ADDRESS"
curl $JSON_RPC -X 'POST' -H 'Content-Type: application/json' --data "{\"jsonrpc\":\"2.0\", \"id\":1, \"method\": \"eth_sendTransaction\", \"params\": [{\"from\":\"$MY_ADDRESS\",\"to\":\"0x$DEPLOYER\", \"gas\":\"0xf4240\", \"data\":\"0x$SALT_HEX$BYTECODE\"}]}"
