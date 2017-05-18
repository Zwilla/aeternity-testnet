#!/usr/bin/env bash
#this quickly tests lightning payments. It is a lot faster and easier than using the browser to test the same thing.

#first run lightning_test_setup to copy the software into 2 other directories.
#Open up 3 terminals.
#Launch one using port 3010, one on 3020, and one on 3030.
#Then run this script from a fourth terminal.

#It lightning spends 4 coins one way, then spends the same 4 back.
echo "####################### add peer 3030 to 3011 #######################\n"
curl -i -d '["add_peer", [127,0,0,1], 3030]' http://localhost:3011

echo "\n####################### add peer 3020 to 3011 #######################\n"
curl -i -d '["add_peer", [127,0,0,1], 3020]' http://localhost:3011

echo "\n####################### add peer 3010 to 3011 #######################\n"
curl -i -d '["add_peer", [127,0,0,1], 3010]' http://localhost:3011
echo "\n####################### sync peer 3020 with 3011 ####################\n"
curl -i -d '["sync", [127,0,0,1], 3020]' http://localhost:3011
echo "\n####################### sync peer 3030 with 3011 ####################\n"
curl -i -d '["sync", [127,0,0,1], 3030]' http://localhost:3011

echo "\n####################### create account (1) on 3011 ######################\n"
curl -i -d '["create_account", "SlZSdjZTcnFEQ1BpOGZ0RTVB", 10, 2]' http://localhost:3011
sleep 1
echo "\n####################### create account (2) on 3011 ######################\n"
curl -i -d '["create_account", "RlpkWGRweGtrenlVS2U1TERW", 10, 3]' http://localhost:3011
sleep 1
echo "\n####################### sync peer 3030 with 3011 ########################\n"
curl -i -d '["sync", [127,0,0,1], 3030]' http://localhost:3011
sleep 1
echo "\n####################### sync peer 3030 with 3021 ########################\n"
curl -i -d '["sync", [127,0,0,1], 3030]' http://localhost:3021
sleep 1

echo "\n####################### 2 step handshake to make channel ################"
echo "####################### new_channel_with_server on 3030  - 3011 #########\n"
curl -i -d '["new_channel_with_server", [127,0,0,1], 3030, 1, 10000, 10001, 50, 4]' http://localhost:3011
sleep 5
echo "\n####################### sync peer 3030 with 3021 ########################\n"
curl -i -d '["sync", [127,0,0,1], 3030]' http://localhost:3021
sleep 1
echo "\n####################### new_channel_with_server on 3030  - 3021 #########\n"
curl -i -d '["new_channel_with_server", [127,0,0,1], 3030, 2, 10000, 10001, 50, 4]' http://localhost:3021
sleep 5
echo "\n####################### sync peer 3030 with 3011 ########################\n"
curl -i -d '["sync", [127,0,0,1], 3030]' http://localhost:3011
sleep 1

echo "\n####################### 2 step handshake for lightning spend ############"
echo "####################### new_channel_with_server on 3030  - 3011 #########\n"
curl -i -d '["lightning_spend", [127,0,0,1], 3030, 2, 4, 10]' http://localhost:3011
sleep 1
echo "\n####################### learn_secret on 3021 #############################\n"
curl -i -d '["learn_secret", "AgAAAAwr/nWTT4zbCS4lAuc=","WgAAAAAAOkYAAAAAMgAAAAABAAAAAACEC0dIFBQoAgAAAAx3wv4k7MKMmFva1BoKOhYUFhRGAAAAAAAAAAAAAgAAACcQRwAAAAAxAAAAAAEAAAAAAEiECw=="]' http://localhost:3021
sleep 1

echo "\n####################### 3 step handshake #############################"
echo "####################### pull_channel_state from 3030  to 3021 ########\n"
curl -i -d '["pull_channel_state", [127,0,0,1], 3030]' http://localhost:3021
sleep 1

echo "\n####################### 2 step handshake #############################"
echo "####################### bet_unlock from 3030  on 3021 ################\n"
curl -i -d '["bet_unlock", [127,0,0,1], 3030]' http://localhost:3021
sleep 1
echo "\n####################### 3 step handshake #############################"
echo "####################### pull_channel_state from 3030  on 3021 ########\n"
curl -i -d '["pull_channel_state", [127,0,0,1], 3030]' http://localhost:3011
sleep 1

echo "\n####################### TESTS FINISHED ###############################\n"

echo "
  Donate to .. and support Zwilla: \n
  * btc:1DaGkc1Uv4GeCSpjkrMVzCA35ENmrd526V \n
  * eth:0x284DbB6139e2e08cd3D3BE6f51306c19cAB04e3c \n
  * ltc:LNvu63U68G72KXHWP5yqSuSYpoa7ef58c7 \n
  "
#curl -i -d '["lightning_spend", [127,0,0,1], 3030, 0, 4]' http://localhost:3021
#sleep 1
#curl -i -d '["get_msg", [127,0,0,1], 3030]' http://localhost:3011
#sleep 1
#curl -i -d '["get_msg", [127,0,0,1], 3030]' http://localhost:3021
#sleep 1