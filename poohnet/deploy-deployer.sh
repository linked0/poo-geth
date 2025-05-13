#!/bin/sh

source .env

if [ -z "$1" ]; then
	echo "Usage: $0 <json_rpc>"
	exit 1
fi

if [[ "$1" == "localnet" ]]; then
	L1_RPC_URL=$LOCALNET_RPC_URL
elif [[ "$1" == "devnet" ]]; then
	L1_RPC_URL=$DEVNET_RPC_URL
elif [[ "$1" == "marigold" ]]; then
	L1_RPC_URL=$MARIGOLD_RPC_URL
else
	echo "$1 is not a valid network"
	exit 1
fi

echo "Checking contract size on $L1_RPC_URL"
CODESIZE=$(cast codesize 0x4e59b44847b379578588920cA78FbF26c0B4956C --rpc-url "$L1_RPC_URL")
if [ "$CODESIZE" -gt 0 ]; then
	echo "Contract already deployed"
	exit 1
fi

echo "Sending 1 ETH to deployer"
DEPLOYER_ADDRESS="0x3fAB184622Dc19b6109349B94811493BF2a45362"
AMOUNT="1.0"
cast send "$DEPLOYER_ADDRESS" \
  --value "$(cast to-wei $AMOUNT eth)" \
  --private-key "$ADMIN_KEY" \
  --rpc-url "$L1_RPC_URL"

echo "Deploying contract"
cast publish --rpc-url $L1_RPC_URL 0xf8a58085174876e800830186a08080b853604580600e600039806000f350fe7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe03601600081602082378035828234f58015156039578182fd5b8082525050506014600cf31ba02222222222222222222222222222222222222222222222222222222222222222a02222222222222222222222222222222222222222222222222222222222222222 