* 17th May 2017 @zwilla

# How To?

How to? | COMMAND
------------ | -------------
Starting Testnet | `sh setup_test.sh`
Stop Testnet | `sh initd-aeternity.sh stop`
Access screen session 3010| `screen -r aeternity-3010`
Access screen session 3020| `screen -r aeternity-3020`
Access screen session 3030| `screen -r aeternity-3030`


# How it works!
The script ' [setup_test.sh](https://github.com/Zwilla/aeternity-testnet/blob/master/setup_test.sh) ' will copy 3 times the testnet-folder into:
- aeternity-testnet3010
- aeternity-testnet3020
- aeternity-testnet3030

**(WARNING! DO NOT RUN SCRIPST FROM ..3010/20/30 folders)**
 
 * Than it will compile and clean the testnet.app and 
 * starts a screen session for every NODE!
 
 You can access the every screens session.
 * Node 3010 starts as mining node
 * Node 3020 and 3030 as full node

 To make some tests run this script:
 [lightning_test.sh](https://github.com/Zwilla/aeternity-testnet/blob/master/tests/lightning_test.sh)

  
  Donate to .. and support Zwilla:
  * btc: -[1DaGkc1Uv4GeCSpjkrMVzCA35ENmrd526V]
  * eth: -[0x284DbB6139e2e08cd3D3BE6f51306c19cAB04e3c]
  * ltc: -[LNvu63U68G72KXHWP5yqSuSYpoa7ef58c7]
  * aeo: -[0x] (Aeternity Tokens)

  You find this file here: https://github.com/Zwilla/aeternity-testnet/blob/master/docs/testnet.md

  After running the test_setup script you can choose now:

Choose  | COMMAND
------------ | -------------
 (1) update and setup! | will setup update and start your testnet
 (2) start now!        | starts an already installed testnet
 (3) how to?           | shows this file here
 (4) clean             | will clean all and delete the extra folders
 (5) run tests!        | starting lightning test
 (6) exit!             | exit the script