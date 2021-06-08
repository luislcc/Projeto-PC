-module(game_manager).
-export([start/0,stop/0]).


initialize()->
	register(game,spawn_link(fun()-> game_instance(game_state:new_state(), erlang:timestamp()) end)),
	loop([],queue:new()).


loop(Players,Queue)->
	
	QueueState = queue:is_empty(Queue),
	receive 
		{join,Pid} when (not QueueState)-> Pid!{enqueued,game_manager}, loop(Players,queue:snoc(Queue,Pid));

		{join,Pid} when length(Players) < 3 ->  join_game(Pid), loop([Pid | Players],Queue);
		
		{join,Pid} when length(Players) >= 3 ->  Pid!{enqueued,game_manager}, loop(Players,queue:snoc(Queue,Pid));

		{left,Pid,game} when (not QueueState) -> Pid!{left_game,game_manager}, join_game(queue:get(Queue)), loop([queue:get(Queue) | (Players -- [Pid])], queue:drop(Queue));
		
		{left,Pid,game} -> Pid!{left_game,game_manager}, loop((Players -- [Pid]), Queue);

		{died,Pid,game} when (not QueueState) -> Pid!{dead,game_manager}, join_game(queue:get(Queue)), loop([queue:get(Queue) | (Players -- [Pid])], queue:drop(Queue));

		{died,Pid,game} -> Pid!{dead,game_manager}, loop((Players -- [Pid]), Queue),loop(Players,Queue);

		{update,Pid} -> game ! {update,Pid,game_manager}, loop(Players,Queue);

		{update_state,State,Pid,game} -> Pid ! {update,State,game_manager}, loop(Players,Queue);
		
		{leave,Pid} -> Pid!{left_queue,game_manager}, loop(Players,queue:delete(Pid,Queue))
	end.
															


join_game(Pid) ->
	game!{join,Pid,game_manager},
	Pid!{joined_game,game}.




game_instance(State, Timestamp) ->
	%timer:sleep(1),
	TimeNow = erlang:timestamp(),
	TimeDelta = timer:now_diff(TimeNow, Timestamp) / math:pow(10,6),
	%io:format("TIMEDELTA: ~p~n",[TimeDelta]),
	{NewState,Deads} = game_state:calculate_state(State,TimeDelta),
	
	K = game_state:count_players(State),
	%io:format("Number of players: ~p ~n",[K]),
	if 
	 	( K < 1) -> T = infinity; 
	 	true -> T = 0 
	end,
	
	receive
		{w_press,Pid} -> game_instance(game_state:alternate_propulsion(Pid,NewState,true),TimeNow);
		{w_release,Pid} -> game_instance(game_state:alternate_propulsion(Pid,NewState,false),TimeNow);
		{update,Pid,game_manager} -> ?MODULE ! {update_state,NewState,Pid,game};
		
		{a_press,Pid} -> game_instance(game_state:alternate_angular_propulsion(Pid,NewState,(-1)),TimeNow);
		{a_release,Pid} -> game_instance(game_state:alternate_angular_propulsion(Pid,NewState,(1)),TimeNow);
		
		{d_press,Pid} -> game_instance(game_state:alternate_angular_propulsion(Pid,NewState,(1)),TimeNow);
		{d_release,Pid} -> game_instance(game_state:alternate_angular_propulsion(Pid,NewState,(-1)),TimeNow);
		{leave, Pid} -> {Calculated_State,Left} = game_state:remove_player(NewState,Pid), game_manager!{left,Left,game}, game_instance(Calculated_State,TimeNow);

		{join,Pid,game_manager} -> game_instance(game_state:create_player(NewState,Pid,5),erlang:timestamp())

	after T -> true
	end,

	[?MODULE ! {died,Dead,game} || Dead <- Deads],
	%?MODULE ! {update_state,NewState,game},
	%game_state:print_stt(State),
	game_instance(NewState,TimeNow).



% -module(test).
% -export([init/0,tester/1]).

% tester(Guys)->
%     if Guys < 3 -> T = infinity;
%         true -> T = 0 end,
%     receive
%         hey -> io:format("Hello ~n"), tester(Guys+1)

%     after T -> io:format("loop"), tester(Guys)
%     end. 

%init() -> register(?MODULE, spawn(fun() -> tester(0) end)). 


start()-> register(?MODULE,spawn(fun()-> initialize() end )).

stop()-> ?MODULE! stop.