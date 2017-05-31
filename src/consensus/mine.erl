-module(mine).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,
	 handle_info/2,init/1,terminate/2,
	 start/0,stop/0,status/0]).
init(ok) -> {ok, stop}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast(mine, go) ->
    case free_constants:test_mode() of
	true ->
	    spawn(fun() ->
	    block:mine_blocks(1, 5, 1),
			  mine()
		  end);
	false ->
    spawn(fun() ->
			  block:mine_blocks(1, 1000000),
			  mine()
		  end)
    end,
    {noreply, go};
handle_cast(start, stop) ->
    Cores = block:guess_number_of_cpu_cores(),
    io:fwrite("start mining with"),
    io:fwrite(integer_to_list(Cores)),
    io:fwrite(" cores.\n"),
    {noreply, go};
handle_cast(stop, _) ->
    {noreply, stop};
handle_cast(_, X) -> {noreply, X}.
handle_call(status, _From, X) -> {reply, X, X};
handle_call(_, _From, X) -> {reply, X, X}.

start() ->
    sync:start(),
    gen_server:cast(?MODULE, start),
    timer:sleep(100),
    mine().
mine() ->
    gen_server:cast(?MODULE, mine).

stop() -> gen_server:cast(?MODULE, stop).
status() ->
    gen_server:call(?MODULE, status).
