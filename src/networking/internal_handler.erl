
-module(internal_handler).

-export([init/3, handle/2, terminate/3, doit/1]).
%example of talking to this handler:
%httpc:request(post, {"http://127.0.0.1:3011/", [], "application/octet-stream", packer:pack({pubkey})}, [], []).
%curl -i -d '[-6,"test"]' http://localhost:3011

handle(Req, State) ->
    {ok, Data, _} = cowboy_req:body(Req),
    %io:fwrite("internal handler "),
    %io:fwrite(Data),
    %io:fwrite("\n"),
    true = is_binary(Data),
    A = packer:unpack(Data),
    B = doit(A),
    D = packer:pack(B),
    Headers = [{<<"content-type">>, <<"application/octet-stream">>},
    {<<"Access-Control-Allow-Origin">>, <<"*">>}],
    {ok, Req2} = cowboy_req:reply(200, Headers, D, Req),
    {ok, Req2, State}.
init(_Type, Req, _Opts) -> {ok, Req, no_state}.
terminate(_Reason, _Req, _State) -> ok.
-define(POP, <<1,6,3,87,3,5>>).
doit({sign, Tx}) -> 
    {Trees,_,_} = tx_pool:data(),
    Accounts = trees:accounts(Trees),
    {ok, keys:sign(Tx, Accounts)};


doit({balance}) ->
    {ok, accounts:balance(block_tree:account(keys:id()))};
doit({create_account, Address, Amount, ID}) -> 
    easy:create_account(Address, Amount, ID),
    %tx_pool_feeder:absorb(keys:sign(create_account_tx:create_account(Address, Amount, Fee, ID, Accounts))),
    {ok, ok};
doit({spend, To, Amount}) ->
    easy:spend(To, Amount),
    {ok, ok};
doit({mine_block}) -> 
    block:mine_blocks(1, 100000000);
doit({mine_block, Many, Times}) -> 
    block:mine_blocks(Many, Times);
doit({close_channel, IP, Port}) ->
    {ok, PeerId} = talker:talk({id}, IP, Port),
    {ok, CD} = channel_manager:read(PeerId),
    SPK = testnet_sign:data(channel_feeder:them(CD)),
    {Trees,_,_} = tx_pool:data(),
    Height = block:height(block:read(top:doit())),
    SS = channel_feeder:script_sig_them(CD),
    {Amount, _, _, _} = spk:run(fast, SS, SPK, Height, 0, Trees),
    CID = spk:cid(SPK),
    Fee = free_constants:tx_fee(),
    {Tx, _} = channel_team_close_tx:make(CID, Trees, Amount, [], Fee),
    Accounts = trees:accounts(Trees),
    STx = keys:sign(Tx, Accounts),
    {ok, SSTx} = talker:talk({close_channel, CID, keys:id(), SS, STx}, IP, Port),
    tx_pool_feeder:absorb(SSTx),
    {ok, 0};
doit({dice, Amount, IP, Port}) ->
    %{ok, Other} = talker:talk({id}, IP, Port),
    {Commit, Secret} = secrets:new(),
    MyID = keys:id(),
    {ok, SSPK, OtherCommit} = talker:talk({dice, 1, MyID, Commit, Amount}, IP, Port),
    SSPK2 = channel_feeder:agree_bet(dice, SSPK, [Amount, Commit, OtherCommit], Secret),%should store partner's info into channel manager.
    %ok;%comment below this line for testing channel_slash txs.
    SPK = testnet_sign:data(SSPK2),
    SS1 = dice:make_ss(SPK, Secret),
    {ok, SSPKsimple, TheirSecret} = talker:talk({dice, 2, MyID, SSPK2, SS1}, IP, Port), %SSPKsimple doesn't include the bet. the result of the bet instead is recorded.
    %ok;%comment below this line for testing channel_slash txs.
    SS = dice:resolve_ss(SPK, Secret, TheirSecret),%
    SSPK2simple = channel_feeder:agree_simplification(dice, SSPKsimple, [SS]),
    SPKsimple = testnet_sign:data(SSPKsimple),
    SPKsimple = testnet_sign:data(SSPK2simple),
    talker:talk({dice, 3, MyID, SSPK2simple}, IP, Port);
doit({channel_solo_close, Other}) ->
    Fee = free_constants:tx_fee(),
    {Trees,_,_} = tx_pool:data(),
    Accounts = trees:accounts(Trees),
    {ok, CD} = channel_manager:read(Other),
    SSPK = channel_feeder:them(CD),
    SS = channel_feeder:script_sig_them(CD),
    {Tx, _} = channel_solo_close:make(keys:id(), Fee, keys:sign(SSPK, Accounts), SS, Trees),
    STx = keys:sign(Tx, Accounts),
    tx_pool_feeder:absorb(STx),
    {ok, ok};
    
doit({add_peer, IP, Port}) ->
    peers:add(IP, Port);
doit({sync, IP, Port}) ->
    MyHeight = block:height(block:read(top:doit())),
    download_blocks:sync(IP, Port, MyHeight);
doit({top}) -> 
    Top = block:read(top:doit()),
    Height = block:height(Top),
    TopHash = block:hash(Top),
    {ok, TopHash, Height};
doit({pubkey}) -> {ok, keys:pubkey()};
doit({address}) -> {ok, testnet_sign:pubkey2address(keys:pubkey())};
doit({address, X}) -> {ok, testnet_sign:pubkey2address(X)};
doit({id}) -> {ok,  keys:id()};
doit({channel_ids, Partner}) -> {ok, channel_manager:read(Partner)};
doit({new_pubkey, Password}) -> 
    keys:new(Password);
doit({test}) -> 
    {test_response};
doit({channel_spend, IP, Port, Amount}) ->
    {ok, PeerId} = talker:talk({id}, IP, Port),
    {ok, CD} = channel_manager:read(PeerId),
    OldSPK = testnet_sign:data(channel_feeder:them(CD)),
    ID = keys:id(),
    {Trees,_,_} = tx_pool:data(),
    Accounts = trees:accounts(Trees),
    SPK = spk:get_paid(OldSPK, ID, -Amount), 
    Payment = keys:sign(SPK, Accounts),
    M = {channel_payment, Payment, Amount},
    {ok, Response} = talker:talk(M, IP, Port),
    %maybe verify the signature of Response here?
    channel_feeder:spend(Response, -Amount),
    {ok, ok};
    
doit({new_channel_with_server, IP, Port, CID, Bal1, Bal2, Fee, Delay}) ->
    %make sure we don't already have a channel with this peer.
    easy:new_channel_with_server(IP, Port, CID, Bal1, Bal2, Fee, Delay),
    {ok, 0};
doit({learn_secret, Secret, Code}) ->
    secrets:add(Code, Secret),
    {ok, 0};
doit({push_channel_state, IP, Port, SS}) ->
    {ok, ServerID} = talker:talk({id}, IP, Port),
    push_channel_state_internal(IP, Port, SS, ServerID);
doit({pull_channel_state, IP, Port}) ->
    %If your channel partner has a script sig that you don't know about, this is how you download it
    {ok, ServerID} = talker:talk({id}, IP, Port),
    {ok, CD0} = channel_manager:read(ServerID),
    true = channel_feeder:live(CD0),
    SPKME = channel_feeder:me(CD0),
    CID = spk:cid(SPKME),
    {ok, CD, ThemSPK} = talker:talk({spk, CID}, IP, Port),
    Return = channel_feeder:they_simplify(ServerID, ThemSPK, CD),
    talker:talk({channel_sync, keys:id(), Return}, IP, Port),
    {ok, 0};
doit({bet_unlock, IP, Port}) ->
    %look at the list of contracts that can be spent, see if the answers are in secrets.erl
    {ok, ServerID} = talker:talk({id}, IP, Port),
    {ok, CD0} = channel_manager:read(ServerID),
    CID = channel_feeder:cid(CD0),
    [{Secrets, SPK}] = channel_feeder:bets_unlock([ServerID]),
    teach_secrets(keys:id(), Secrets, IP, Port),
    {Trees, _, _} = tx_pool:data(),
    Accounts = trees:accounts(Trees),
    talker:talk({channel_sync, keys:id(), keys:sign(SPK, Accounts)}, IP, Port),
    {ok, _CD, ThemSPK} = talker:talk({spk, CID}, IP, Port),
    channel_feeder:update_to_me(ThemSPK, ServerID),
    {ok, 0};
doit({lightning_spend, IP, Port, Recipient, Amount, Fee}) ->
    %payment is routed through this server, and to the recipient.
    {Code, SS} = secrets:new_lightning(),
    doit({lightning_spend, IP, Port, Recipient, Amount, Fee, Code, SS});
doit({lightning_spend, IP, Port, Recipient, Amount, Fee, Code, SS}) ->
    {ok, ServerID} = talker:talk({id}, IP, Port),
    %ChannelID,
    SSPK = channel_feeder:make_locked_payment(ServerID, Amount+Fee, Code, []),
    {ok, SSPK2} = talker:talk({locked_payment, SSPK, Amount, Fee, Code, keys:id(), Recipient}, IP, Port),
    {Trees, _, _} = tx_pool:data(),
    Accounts = trees:accounts(Trees),
    true = testnet_sign:verify(keys:sign(SSPK2, Accounts), Accounts),
    SPK = testnet_sign:data(SSPK),
    SPK = testnet_sign:data(SSPK2),
    %store SSPK2 in channel manager, it is their most recent signature.
    {ok, CD} = channel_manager:read(ServerID),
    CID = channel_feeder:cid(CD),
    Entropy = channel_feeder:entropy(CD),
    ThemSS = channel_feeder:script_sig_them(CD),
    MeSS = channel_feeder:script_sig_me(CD),
    NewCD = channel_feeder:new_cd(SPK, SSPK2, [<<>>|ThemSS], [<<>>|MeSS], Entropy, CID),
    channel_manager:write(ServerID, NewCD),
    io:fwrite("give this secret to your partner so that they can receive the payment --------> "
	      ++ binary_to_list(base64:encode(SS))
	      ++ "  |  "
	      ++ binary_to_list(base64:encode(Code))
				++ " <-------- \n"),
    {ok, 0};
doit({channel_keys}) -> {ok, channel_manager:keys()};
doit({block_tree_account, Id}) -> {ok, block_tree:account(Id)};
doit({halt}) -> {ok, testnet_sup:stop()};
doit({key_status}) -> {ok, list_to_binary(atom_to_list(keys:status()))};
doit({key_unlock, Password}) -> {ok, list_to_binary(atom_to_list(keys:unlock(Password)))};
doit({keys_id_update, ID}) -> 
    keys:update_id(ID),
    {ok, 0};
doit({key_new, Password}) -> 
    keys:new(Password),
    {ok, 0};

doit(X) ->
    io:fwrite("don't know how to handle it \n"),
    io:fwrite(packer:pack(X)),
    io:fwrite("\n"),
    {error}.
teach_secrets(_, [], _, _) -> ok;
teach_secrets(ID, [{secret, Secret, Code}|Secrets], IP, Port) ->
    talker:talk({learn_secret, ID, Secret, Code}, IP, Port),
    teach_secrets(ID, Secrets, IP, Port).
push_channel_state_internal(IP, Port, SS, ServerID) ->
    {ok, CD} = channel_manager:read(ServerID),
    %{SS2, Return} = channel_feeder:we_simplify(ServerID, SS),
    {Trees, _, _} = tx_pool:data(),
    Accounts = trees:accounts(Trees),
    Return = keys:sign(channel_feeder:me(CD), Accounts),
    %SS = channel_feeder:script_sig_me(CD),
    {ok, ThemSPK} = talker:talk({push_spk, Return, SS}, IP, Port),
    true = testnet_sign:verify(keys:sign(ThemSPK, Accounts), Accounts),
    SPK = testnet_sign:data(ThemSPK),
    SPK = testnet_sign:data(Return),
    CID = spk:cid(channel_feeder:me(CD)),
    Data = channel_feeder:new_cd(SPK, ThemSPK, SS, SS, channel_feeder:entropy(CD), CID),
    channel_manager:write(CID, Data),
    {ok, 0}.

