-module(game_manager).
-export([start/0,stop/0]).


initialize()->
	register(game,spawn_link(fun()-> game_instance(game_state:new_state(), erlang:timestamp(),erlang:timestamp()) end)),
	loop(#{},[],queue:new()).


loop(LeaderBoard,Players,Queue)->
	%io:format("LEADERBOARD: ~p~n",[LeaderBoard]),
	QueueState = queue:is_empty(Queue),
	receive 
		{join,Pid,Username} when (not QueueState)-> Pid!{enqueued,game_manager}, loop(LeaderBoard,Players,queue:snoc(Queue,{Pid,Username}));

		{join,Pid,Username} when length(Players) < 3 ->  join_game({Pid,Username}), loop(maps:put(Username,0,LeaderBoard),[{Pid,Username} | Players],Queue);
		
		{join,Pid,Username} when length(Players) >= 3 ->  Pid!{enqueued,game_manager}, loop(LeaderBoard,Players,queue:snoc(Queue,{Pid,Username}));

		{left,Pid,Username,game} when (not QueueState) -> Pid!{left_game,game_manager}, join_game(queue:get(Queue)), loop(LeaderBoard,[queue:get(Queue) | (Players -- [{Pid,Username}])], queue:drop(Queue));
		
		{left,Pid,Username,game} -> Pid!{left_game,game_manager}, loop(LeaderBoard,(Players -- [{Pid,Username}]), Queue);

		{died,Pid,Username,game} when (not QueueState) -> Pid!{dead,game_manager}, join_game(queue:get(Queue)), loop(LeaderBoard,[queue:get(Queue) | (Players -- [{Pid,Username}])], queue:drop(Queue));

		{died,Pid,Username,game} -> Pid!{dead,game_manager}, loop(LeaderBoard,(Players -- [{Pid,Username}]), Queue),loop(LeaderBoard,Players,Queue);

		{update,Pid} -> game ! {update,Pid,game_manager}, loop(LeaderBoard,Players,Queue);

		{update_state,State,Pid,game} -> Pid ! {update,State,LeaderBoard,game_manager}, loop(LeaderBoard,Players,Queue);
		
		{points,GamePoints,game} -> loop(update_points(LeaderBoard,GamePoints),Players,Queue);

		{leave,Pid} -> Pid!{left_queue,game_manager}, loop(LeaderBoard,Players,queue:delete(Pid,Queue))
	end.


update_points(LeaderBoard,Current)->
	if
		length(Current) < 1 -> LeaderBoard;
		true -> [{Username,Points} | T] = Current, CurrentUserPoints = maps:get(Username,LeaderBoard), 
				if
					Points > CurrentUserPoints -> update_points(maps:put(Username,CurrentUserPoints,LeaderBoard),T);
					true -> update_points(LeaderBoard,T)
				end 
	end.
															


join_game(Joining) ->
	{Pid,Username} = Joining,
	game!{join,Pid,Username,game_manager},
	Pid!{joined_game,game}.




game_instance(State, Timestamp, TimeStampCreatures) ->
	%timer:sleep(1),
	TimeNow = erlang:timestamp(),
	TimeDelta = timer:now_diff(TimeNow, Timestamp) / math:pow(10,6),
	%io:format("TIMEDELTA: ~p~n",[TimeDelta]),
	{NewState,Deads,LastSpawnCreatures} = game_state:calculate_state(State,TimeDelta,TimeStampCreatures),
	
	K = game_state:count_players(State),
	%io:format("Number of players: ~p ~n",[K]),
	if 
	 	( K < 1) -> T = infinity; 
	 	true -> T = 0 
	end,
	
	receive
		{w_press,Pid} -> game_instance(game_state:alternate_propulsion(Pid,NewState,true),TimeNow,LastSpawnCreatures);
		{w_release,Pid} -> game_instance(game_state:alternate_propulsion(Pid,NewState,false),TimeNow,LastSpawnCreatures);
		{update,Pid,game_manager} -> ?MODULE ! {update_state,NewState,Pid,game};
		
		{a_press,Pid} -> game_instance(game_state:alternate_angular_propulsion(Pid,NewState,(-1)),TimeNow,LastSpawnCreatures);
		{a_release,Pid} -> game_instance(game_state:alternate_angular_propulsion(Pid,NewState,(1)),TimeNow,LastSpawnCreatures);
		
		{d_press,Pid} -> game_instance(game_state:alternate_angular_propulsion(Pid,NewState,(1)),TimeNow,LastSpawnCreatures);
		{d_release,Pid} -> game_instance(game_state:alternate_angular_propulsion(Pid,NewState,(-1)),TimeNow,LastSpawnCreatures);
		{leave, Pid} -> U = maps:get(username,element(2,NewState)),{Calculated_State,Left} = game_state:remove_player(NewState,Pid), game_manager!{left,Left,U,game}, game_instance(Calculated_State,TimeNow,LastSpawnCreatures);

		{join,Pid,Username,game_manager} -> game_instance(game_state:create_player(NewState,Pid,5,Username),erlang:timestamp(),LastSpawnCreatures)

	after T -> true
	end,

	[?MODULE ! {died,Dead,game} || Dead <- Deads],
	?MODULE ! {points,game_state:get_points(State),game},
	%?MODULE ! {update_state,NewState,game},
	%game_state:print_stt(State),
	game_instance(NewState,TimeNow,LastSpawnCreatures).



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