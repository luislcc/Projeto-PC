-module(game).
-export([start/0]).


timeToCreatures() ->
	500.


game_starter(LeaderBoard)->
	receive
		{toJoin,Pid,Username,queue_manager} -> State = gameEngine:addPlayer(Pid,Username,gameEngine:newState()),spawn(fun()-> mob_spawner() end),game_instance([Pid],LeaderBoard,State,erlang:timestamp());
		_ -> game_starter(LeaderBoard)
	end.


game_instance(Players,LeaderBoard,State,Timestamp) ->
	timer:sleep(1), %% Sleep da Sorte %%
	TimeDelta = timer:now_diff(erlang:timestamp(),Timestamp)/math:pow(10,6),
	if
		length(Players) < 1 -> game_starter(LeaderBoard);
		true -> ok
	end,
	receive
		{w_press,Pid} -> NewState = gameEngine:applyUserInput(Pid,State,w,d), NewPlayers = Players;
		{a_press,Pid} -> NewState = gameEngine:applyUserInput(Pid,State,a,d), NewPlayers = Players;
		{d_press,Pid} -> NewState = gameEngine:applyUserInput(Pid,State,d,d), NewPlayers = Players;
		
		{w_release,Pid} -> NewState = gameEngine:applyUserInput(Pid,State,w,u), NewPlayers = Players;
		{a_release,Pid} -> NewState = gameEngine:applyUserInput(Pid,State,a,u), NewPlayers = Players;
		{d_release,Pid} -> NewState = gameEngine:applyUserInput(Pid,State,d,u), NewPlayers = Players;
		
		{createCreature,spawner} -> spawn(fun()-> mob_spawner() end),NewState = gameEngine:probableCreature(State),NewPlayers = Players; 
		{toJoin,Pid,Username,queue_manager} ->NewState = gameEngine:addPlayer(Pid,Username,State), NewPlayers = Players ++ [Pid];
		{leave,Pid} ->Pid!{left,game}, NewState = gameEngine:removePlayer(Pid,State), queue_manager!{left,game}, NewPlayers = Players --[Pid];
		_ -> NewState = State, NewPlayers = Players
		after 0 -> NewState = State, NewPlayers = Players
	end,
	
	{NextState,Deads} = gameEngine:calculateState(NewState,TimeDelta),
	CurrentPoints = gameEngine:getPoints(NextState),
	NewLeaderBoard = updateLeaderBoard(LeaderBoard,CurrentPoints),

	[PidK!{dead,game}|| PidK <- Deads],
	[queue_manager!{left,game}|| _ <- Deads],
	
	NextPlayers = (NewPlayers -- Deads),
	[PidL!{update,NextState,LeaderBoard,game} || PidL <- NextPlayers],
	%io:format("~p~n",[element(2,NextState)]),
	game_instance(NextPlayers, NewLeaderBoard ,NextState , erlang:timestamp()).



mob_spawner() ->
	timer:sleep(timeToCreatures()),
	?MODULE!{createCreature,spawner}.



updateLeaderBoard(LeaderBoard,Current)->
	if
		length(Current) < 1 -> LeaderBoard;
		true -> [{Username,Points} | T] = Current, CurrentUserPoints = maps:get(Username,LeaderBoard,0), 
				if
					Points >= CurrentUserPoints -> updateLeaderBoard(maps:put(Username,Points,LeaderBoard),T);
					true -> updateLeaderBoard(LeaderBoard,T)
				end 
	end.

start()-> register(?MODULE,spawn(fun()-> game_starter(#{}) end )).