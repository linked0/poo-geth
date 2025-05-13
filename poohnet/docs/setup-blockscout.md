# Setup Blockscout

## Reference Site
You can setup a blockscout with [Blockscout Manual Deployment Guide](https://docs.blockscout.com/for-developers/deployment/manual-deployment-guide)

### Setting for Poohnet
You should set env variables for Poohnet as follows
```
# Blockscout
export DATABASE_URL=postgresql://postgres:12345678@127.0.0.1:5432/blockscout?ssl=false
export DB_HOST=127.0.0.1
export DB_PASSWORD=12345678
export DB_PORT=5432
export DB_USERNAME=postgres

export SECRET_KEY_BASE=9bv/ci2b7d4cbZIXyVf/HnFnzB8yffuHf/QY438IqKlA2u3hR3tacxEaZH3g4rI6

export ETHEREUM_JSONRPC_VARIANT=geth
export ETHEREUM_JSONRPC_HTTP_URL=http://localhost:8545
export API_V2_ENABLED=true
export PORT=14000
export COIN=POO
export COIN_NAME=POOHNET
export DISPLAY_TOKEN_ICONS=true

export ETHEREUM_JSONRPC_TRANSPORT=ipc
export IPC_PATH=$HOME/.pooh/el/geth.ipc
```


## New configuration for working with Blockscout
There might be some error message in Blockscout logs if you don't run the Poohnet node as follows.
```
2024-04-24T15:44:46.809 application=indexer fetcher=internal_transaction count=1 error_count=1 [error] failed to fetch internal transactions for blocks: ** (ErlangError) Erlang error: [%{code: -32601, data: %{block_number: 365, transaction_hash: "0x20d0bdc22e02ad46076d015d7c53bf5582f59ff6cef31dea6be8525d1019db7e", transaction_index: 0}, message: "the method debug_traceTransaction does not exist/is not available"}]
```

So you should add the `debug` mode in `http.api` configure in your docker compose yaml file as follows.
```
command: --datadir=/data --syncmode=full --networkid=12301 --bootnodes="enode://6d59a1ce195d9251e8f5234b3dbd486cf15eeac6cb8199898af3e11b9b7f5c54e334317d1cc3ab8077360383bc08b8aa93299ccb169b55dbea59414847dbce2d@13.209.149.243:30303" --allow-insecure-unlock=true --unlock=0x8532654aD638Db3deE3836B22B35f7Ca707428ca --password=/root/password.txt --mine=true --rpc.allow-unprotected-txs --metrics --metrics.addr=0.0.0.0 --metrics.port=6060 --miner.etherbase=0x8532654aD638Db3deE3836B22B35f7Ca707428ca --http --http.addr="0.0.0.0" --http.port=8545 --http.corsdomain="*" --http.api="debug,personal,eth,net,txpool,web3" --http.vhosts="*" --ws --ws.port=8546 --ws.api="personal,eth,net,txpool,web3" --ws.origins="*"
```

### HTTP Endpoint configuration in config/dev.exs
```
config :block_scout_web, BlockScoutWeb.Endpoint,
    http: [port: 4000],
    https: [
        port: 4001,
        cipher_suite: :strong,
        certfile: "priv/cert/selfsigned.pem",
        keyfile: "priv/cert/selfsigned_key.pem"
    ],
```

## Errors
### Prometheus_process_collector error
You might get the following error message in running the `mix do deps.get, local.rebar --force, deps.compile` command on Mac which is describe in the [Blockscout manual](https://docs.blockscout.com/for-developers/deployment/manual-deployment-guide).
```
===> Compiling ranch
Error! Failed to eval: io:format("~s/erts-~s/include/", [code:root_dir(), erlang:system_info(version)]).
Error! Failed to eval: io:format("~s", [code:lib_dir(erl_interface, include)]).
c++ -O3 -arch x86_64 -finline-functions -fPIC -I  -I  -std=c++11 -Wall  -c -o prometheus_process_collector_nif.o prometheus_process_collector_nif.cc
prometheus_process_collector_nif.cc:1:10: fatal error: 'erl_nif.h' file not found
#include "erl_nif.h"
         ^~~~~~~~~~~
1 error generated.
make: *** [prometheus_process_collector_nif.o] Error 1
===> Hook for compile failed!
** (Mix) Could not compile dependency :prometheus_process_collector, "/Users/hyunjaelee/.mix/elixir/1-16/rebar3 bare compile --paths /Users/hyunjaelee/work/blockscout-backend/_build/dev/lib/*/ebin" command failed. Errors may have been logged above. You can recompile this dependency with "mix deps.compile prometheus_process_collector --force", update it with "mix deps.update prometheus_process_collector" or clean it with "mix deps.clean prometheus_process_collector"
deps/prometheus_process_collector/c_src/Makefile
```

This error occurs because the following code doesn't work, which is definde in `deps/prometheus_process_collector/c_src/Makefile`. 
```
ERTS_INCLUDE_DIR ?= $(shell erl -noshell -s init stop -eval "io:format(\"~s/erts-~s/include/\", [code:root_dir(), erlang:system_info(version)]).")
ERL_INTERFACE_INCLUDE_DIR ?= $(shell erl -noshell -s init stop -eval "io:format(\"~s\", [code:lib_dir(erl_interface, include)]).")
ERL_INTERFACE_LIB_DIR ?= $(shell erl -noshell -s init stop -eval "io:format(\"~s\", [code:lib_dir(erl_interface, lib)]).")
```

You can solve this problem in two steps.
First, please add env variables in .zshrc(or .bash-profile) as follows.
```
# Blockscout prometheus_process_collector compile
export ERTS_INCLUDE_DIR_POOH="/usr/local/lib/erlang/erts-14.2.4/include"
export ERL_INTERFACE_INCLUDE_DIR_POOH="/usr/local/Cellar/erlang/26.2.4/lib/erlang/lib/erl_interface-5.5.1/include"
export ERL_INTERFACE_LIB_DIR_POOH="/usr/local/Cellar/erlang/26.2.4/lib/erlang/lib/erl_interface-5.5.1/lib"
```

Second, change the code in the file `deps/prometheus_process_collector/c_src/Makefile` as follows.
```
ERTS_INCLUDE_DIR = $(ERTS_INCLUDE_DIR_POOH)
ERL_INTERFACE_INCLUDE_DIR = $(ERL_INTERFACE_INCLUDE_DIR_POOH)
ERL_INTERFACE_LIB_DIR = $(ERL_INTERFACE_LIB_DIR_POOH)
```

### node/npm version error
You should match the node and npm version as requested at the manual. If not, you can get the follow message in running the command `cd apps/explorer && npm install; cd -`
```
npm WARN EBADENGINE Unsupported engine {
npm WARN EBADENGINE   package: undefined,
npm WARN EBADENGINE   required: { node: '18.x', npm: '8.x' },
npm WARN EBADENGINE   current: { node: 'v18.19.1', npm: '10.2.4' }
npm WARN EBADENGINE }
```

You can get the right node version with the requested npm version in [this site](https://nodejs.org/dist/index.json). These are the right version as of writing.
```
$ nvm install v18.13.0
$ nvm use v18.13.0
```

### The input path "priv/static" does not exist error
You can get an error message when running `mix phx.digest` but it doesn't matter. So go through the next steps please.
```
==> ethereum_jsonrpc
The input path "priv/static" does not exist
==> explorer
The input path "priv/static" does not exist
==> indexer
The input path "priv/static" does not exist
==> block_scout_web
Check your digested files at "priv/static"
```

We recommend use `npm ci` instaed of `npm install` for the exact version for node modules.
```
cd apps/block_scout_web/assets; npm ci && node_modules/webpack/bin/webpack.js --mode production; cd -
cd apps/explorer && npm ci; cd -
```
 