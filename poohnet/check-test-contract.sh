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

# 4) The CREATE2 address is the last 20 bytes
MY_CONTRACT_ADDRESS="0x76d0a271b15dea223cf1a00d18b8aa3248305965"

MY_CONTRACT_METHOD_SIGNATURE="c3cafc6f"
curl $JSON_RPC -X 'POST' -H 'Content-Type: application/json' --data "{\"jsonrpc\":\"2.0\", \"id\":1, \"method\": \"eth_call\", \"params\": [{\"to\":\"$MY_CONTRACT_ADDRESS\", \"data\":\"0x$MY_CONTRACT_METHOD_SIGNATURE\"}, \"latest\"]}"
# expected result is 0x000000000000000000000000000000000000000000000000000000000000002a (hex encoded 42)
