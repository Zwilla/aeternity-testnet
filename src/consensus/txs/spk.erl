-module(spk).
-export([acc1/1,acc2/1,entropy/1,
	 bets/1,space_gas/1,time_gas/1,
	 new/9,cid/1,amount/1,
	 nonce/1,apply_bet/5,get_paid/3,
	 run/6,settle_bet/3,chalang_state/3,
	 prove/1, new_bet/3, delay/1,
	 test/0
	]).
-record(bet, {code, amount, prove}).
%We want channel that are using the same contract to be able to calculate a contract hash that is the same. This makes it easier to tell if 2 channels are betting on the same thing.
%Each contract should output an amount between 0 and constants:channel_granularity(), which is the portion of the money that goes to one of the participants. Which participant it signifies depends on what value is stored in a flag.
%So each contract needs a value saying how much of the money is locked into that contract.
-record(spk, {acc1, acc2, entropy, 
	      bets, space_gas, time_gas, 
	      cid, amount = 0, nonce = 0,
	      delay = 0
	     }).
%scriptpubkey is the name that Satoshi gave to this part of the transactions in bitcoin.
%This is where we hold the channel contracts. They are turing complete smart contracts.
%Besides the SPK, there is the ScriptSig. Both participants of the channel sign the SPK, only one signs the SS.
delay(X) -> X#spk.delay.
acc1(X) -> X#spk.acc1.
acc2(X) -> X#spk.acc2.
bets(X) -> X#spk.bets.
entropy(X) -> X#spk.entropy.
space_gas(X) -> X#spk.space_gas.
time_gas(X) -> X#spk.time_gas.
cid(X) -> X#spk.cid.
amount(X) -> X#spk.amount.
nonce(X) -> X#spk.nonce.

bet_amount(X) -> X#bet.amount.
prove(X) -> X#bet.prove.
code(X) -> X#bet.code.

prove_facts([], _) ->
    <<>>;
prove_facts(X, Trees) ->
	   %[int 5,int 6,int 7]
    A = <<"macro [ nil ;
	macro , swap cons ;
	macro ] swap cons reverse ;
        [">>,
    B = prove_facts2(X, Trees),
    compiler_chalang:doit(<<A/binary, B/binary>>).
prove_facts2([], _) ->
    <<"]">>;
prove_facts2([{Tree, Key}|T], Trees) ->
    ID = tree2id(Tree),
    Branch = trees:Tree(Trees),
    {_, Data, _} = Tree:get(Key, Branch),
    SerializedData = Tree:serialize(Data),
    Size = size(SerializedData),
    A = "[int " ++ integer_to_list(ID) ++
	", int " ++ integer_to_list(Key) ++%burn and existence store by hash, not by integer.
	", binary " ++
	integer_to_list(Size) ++ " " ++
	binary_to_list(base64:encode(Tree:serialize(Data)))++
	"]",%this comma is used one too many times.
    A2 = list_to_binary(A),
    B = prove_facts2(T, Trees),
    C = case T of
	    [] -> <<>>;
	    _ -> <<", ">>
		     end,
    <<A2/binary, C/binary, B/binary>>.

tree2id(accounts) ->1;
tree2id(channels) -> 2;
tree2id(existence) -> 3;
tree2id(burn) -> 4;
tree2id(oracles) -> 5;
tree2id(governance) -> 6.

new_bet(Code, Amount, Prove) ->
    #bet{code = Code, amount = Amount, prove = Prove}.
new(Acc1, Acc2, CID, Bets, SG, TG, Nonce, Delay, Entropy) ->
    %Prove = many([], length(Bets)),
    #spk{acc1 = Acc1, acc2 = Acc2, entropy = Entropy,
	 bets = Bets, space_gas = SG, time_gas = TG,
	 cid = CID, nonce = Nonce, delay = Delay}.
many(_, 0) -> [];
many(X, N) -> [X|many(X, N-1)].
    
apply_bet(Bet, Amount, SPK, Time, Space) ->
%bet is binary, the SPK portion of the script.
%SPK is the old SPK, we output the new one.
    SPK#spk{bets = [Bet|SPK#spk.bets], 
	    nonce = SPK#spk.nonce + 1, 
	    time_gas = SPK#spk.time_gas + Time, 
	    space_gas = max(SPK#spk.space_gas, Space),
	    amount = SPK#spk.amount + Amount}.
settle_bet(SPK, Bets, Amount) ->
    SPK#spk{bets = Bets, amount = Amount, nonce = SPK#spk.nonce + 1}.
get_paid(SPK, MyID, Amount) -> %if Amount is positive, that means money is going to Aid2.
    Aid1 = SPK#spk.acc1,
    Aid2 = SPK#spk.acc2,
    D = case MyID of
	Aid1 -> -1;
	Aid2 -> 1;
	_ -> MyID = Aid1
    end,
    SPK#spk{amount = (SPK#spk.amount + (D*Amount)), 
	    nonce = SPK#spk.nonce + 1}.
	    
run(Mode, SS, SPK, Height, Slash, Trees) ->
    %Accounts = trees:accounts(Trees),
    %Channels = trees:channels(Trees),
    %State = chalang:new_state(0, Height, Slash, 0, Accounts, Channels),
    State = chalang_state(Height, Slash, Trees),
    {Amount, NewNonce, CodeShares, Delay, _} = run2(Mode, SS, SPK, State, Trees),
    true = NewNonce < 1000,
    Shares = shares:from_code(CodeShares),
    {Amount + SPK#spk.amount, NewNonce + (1000 * SPK#spk.nonce), Shares, Delay}.
run2(fast, SS, SPK, State, Trees) -> 
    Governance = trees:governance(Trees),
    FunLimit = governance:get_value(fun_limit, Governance),
    VarLimit = governance:get_value(var_limit, Governance),
    true = is_list(SS),
    Bets = SPK#spk.bets,
    %Scripts = bets2scripts(Bets, Trees),
    Delay = SPK#spk.delay,
    run(SS,
	Bets,
		SPK#spk.time_gas,
		SPK#spk.space_gas,
		FunLimit,
		VarLimit,
	State,
	Delay);
run2(safe, SS, SPK, State, Trees) -> 
    %will not crash. if the thread that runs the code crashes, or takes too long, then it returns {-1,-1,-1,-1}
    S = self(),
    spawn(fun() ->
		  X = run2(fast, SS, SPK, State, Trees),
		  S ! X
	  end),
    spawn(fun() ->
		  timer:sleep(5000),%wait enough time for the chalang contracts to finish
		  S ! {-1,-1,-1,-1, -1}
	  end),
    receive 
	Z -> Z
    end.
%bets2scripts([], _) -> [];
%bets2scripts([B|T], Trees) ->
%    F = prove_facts(B#bet.prove, Trees),
%    C = B#bet.code,
%    [<<F/binary, C/binary>>|bets2scripts(T, Trees)].
chalang_state(Height, Slash, Trees) ->
    chalang:new_state(Height, Slash, Trees).
run(ScriptSig, Codes, OpGas, RamGas, Funs, Vars, State, SPKDelay) ->
    run(ScriptSig, Codes, OpGas, RamGas, Funs, Vars, State, 0, 0, SPKDelay, []).

run([], [], OpGas, RamGas, Funs, Vars, State, Amount, Nonce, Delay, ShareRoot) ->
    {Amount, Nonce, ShareRoot, Delay, OpGas};
run([SS|SST], [Code|CodesT], OpGas, RamGas, Funs, Vars, State, Amount, Nonce, Delay, Share0) ->
    {A2, N2, Share, Delay2, EOpGas} =
	run3(SS, Code, OpGas, RamGas, Funs, Vars, State),
    run(SST, CodesT, EOpGas, RamGas, Funs, Vars, State, A2+Amount, N2+Nonce, max(Delay, Delay2), Share ++ Share0).
run3(ScriptSig, Bet, OpGas, RamGas, Funs, Vars, State) ->
    %io:fwrite("script sig is "),
    %compiler_chalang:print_binary(ScriptSig),
    %io:fwrite("spk is "),
    %compiler_chalang:print_binary(ScriptPubkey),
    true = chalang:none_of(ScriptSig),
    {Trees, _, _} = tx_pool:data(),
    F = prove_facts(Bet#bet.prove, Trees),
    C = Bet#bet.code,
    Code = <<F/binary, C/binary>>,
    Data = chalang:data_maker(OpGas, RamGas, Vars, Funs, ScriptSig, Code, State),
    %io:fwrite("running script "),
    Data2 = chalang:run5([ScriptSig], Data),
    Data3 = chalang:run5([Code], Data2),
    [ShareRoot|
     [<<Amount:32>>|
      %[<<Direction:32>>|
       [<<Nonce:32>>|
	[<<Delay:32>>|_]]]] = chalang:stack(Data3),%#d.stack,
    io:fwrite("computed delay as "),
    io:fwrite(integer_to_list(Delay)),
    io:fwrite("\n"),
    if
	Delay > 0 ->
	    io:fwrite(chalang:stack(Data3));
	true -> ok
    end,
    io:fwrite("computed nonce as "),
    io:fwrite(integer_to_list(Nonce)),
    io:fwrite("\n"),
    io:fwrite("computed amount as "),
    io:fwrite(integer_to_list(Amount)),
    io:fwrite("\n"),
    A3 = Amount * Bet#bet.amount div constants:channel_granularity(),
    {A3, Nonce, ShareRoot, Delay,
     chalang:time_gas(Data3)
    }.





test() ->
    %test prove_facts.
    {Trees, _, _} = tx_pool:data(),
    Code = prove_facts([{governance, 5},{accounts, 1}], Trees),
    State = chalang_state(1, 0, Trees),
    [[[<<6:32>>, <<5:32>>, Gov5], %6th tree is governance. 5th thing is "delete channel reward"
      [<<1:32>>, <<1:32>>, Acc1]]] = %1st tree is accounts. 1 is for account id 1.
	chalang:vm(Code, 100000, 100000, 1000, 1000, State),
    Governance = trees:governance(Trees),
    {_, Govern5, _} = governance:get(5, Governance),
    Accounts = trees:accounts(Trees),
    {_, Account1, _} = accounts:get(1, Accounts),
    Acc1 = accounts:serialize(Account1),
    Gov5 = governance:serialize(Govern5),
    success.


