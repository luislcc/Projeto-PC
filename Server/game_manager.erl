-module(game_manager).
-export([start/0,stop/0]).


initialize()->
	register(game,spawn_link(fun()-> game_instance(game_state:new_state(), erlang:timestamp()) end)),
	loop([],queue:new()).


loop(Players,Queue)->
	
	QueueState = queue:is_empty(Queue),
	receive 
		{join,Pid} when (not QueueState)-> Pid!{enqueued,self()}, loop(Players,queue:snoc(Queue,Pid));

		{join,Pid} when length(Players) < 3 ->  join_game(Pid), loop([Pid | Players],Queue);
		
		{join,Pid} when length(Players) >= 3 ->  Pid!{enqueued,self()}, loop(Players,queue:snoc(Queue,Pid));

		{left,Pid,game} when (not QueueState) -> Pid!{left_game,self()}, join_game(queue:get(Queue)), loop([queue:get(Queue) | (Players -- [Pid])], queue:drop(Queue));
		
		{left,Pid,game} -> Pid!{left_game,self()}, loop((Players -- [Pid]), Queue);

		{died,Pid,game} when (not QueueState) -> Pid!{dead,self()}, join_game(queue:get(Queue)), loop([queue:get(Queue) | (Players -- [Pid])], queue:drop(Queue));

		{died,Pid,game} -> Pid!{dead,self()}, loop((Players -- [Pid]), Queue);
		
		{leave,Pid} -> Pid!{left_queue,self()}, loop(Players,queue:delete(Pid,Queue))
	end.
															


join_game(Pid) ->
	game!{join,Pid,self()},
	Pid!{joined_game,game}.




game_instance(State, Timestamp) ->
	TimeNow = erlang:timestamp(),
	TimeDelta = timer:now_diff(TimeNow, Timestamp),
	{NewState,Deads} = game_state:calculate_state(State,TimeDelta),
	
	K = game_state:count_players(State),
	if 
	 	( K < 1) -> T = infinity; 
	 	true -> T = 0 
	end,
	
	receive
		{w_press,Pid} -> NewState = game_state:alternate_propulsion(Pid,NewState,true);
		{w_release,Pid} -> NewState = game_state:alternate_propulsion(Pid,NewState,false);
		
		{a_press,Pid} -> NewState = game_state:alternate_angular_propulsion(Pid,NewState,(-1));
		{a_release,Pid} -> NewState = game_state:alternate_angular_propulsion(Pid,NewState,(1));
		
		{d_press,Pid} -> NewState = game_state:alternate_angular_propulsion(Pid,NewState,(1));
		{d_release,Pid} -> NewState = game_state:alternate_angular_propulsion(Pid,NewState,(-1));

		{leave, Pid} -> {NewState,Left} = game_state:remove_player(NewState,Pid), game_manager!{left,Left,game};

		{join,Pid,game_manager} -> NewState = game_state:create_player(NewState,Pid,0)

	after T -> true
	end,

	[game_manager!{died,Dead,game} || Dead <- Deads],
	%update clients,
	game_state:print_stt(State),
	game_instance(State,TimeNow).



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