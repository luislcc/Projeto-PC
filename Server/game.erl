-module(game_instance).
-export([start/0]).


timeToCreatures() ->
	500.


game_starter(LeaderBoard)->
	receive
		{toJoin,Pid} -> State = gameEngine:addPlayer(Pid,gameEngine:newState()),spawn(fun()-> mob_spawner(self())),game_instance([Pid],LeaderBoard,State,erlang:timestamp());
		_ -> game_starter(LeaderBoard)
	end.


game_instance(Players,LeaderBoard,State,Timestamp) ->
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
		
		{createCreature,spawner} -> spawn(fun()-> mob_spawner(self())),NewState = gameEngine:probableCreature(State),NewPlayers = Players; 
		{toJoin,Pid,Username,queue_manager} ->NewState = gameEngine:addPlayer(Pid,Username,State), NewPlayers = Players ++ [Pid];
		{leave,Pid} ->Pid!{left,game}, NewState = gameEngine:removePlayer(Pid,State), queue_manager!{left,game}, NewPlayers = Players --[Pid];
		_ -> ok
		after 0 -> ok
	end,
	
	{NextState,Deads} = gameEngine:calculateState(NewState,TimeDelta),
	CurrentPoints = gameEngine:getPoints(NextState)
	NewLeaderBoard = updateLeaderBoard(LeaderBoard,CurrentPoints)

	[{PidK!{dead,game},queue_manager!{left,game}} || PidK <- Deads],
	NextPlayers = (NewPlayers -- Deads),
	[PidL!{update,NextState,Leaderboard,game} || PidL <- Players],
	
	game_instance(NewPlayers, NewLeaderBoard ,NextState , erlang:timestamp()).



mob_spawner(Pid) ->
	timer:sleep(timeToCreatures()),
	Pid!{createCreature,spawner}.



updateLeaderBoard(LeaderBoard,Current)->
	if
		length(Current) < 1 -> LeaderBoard;
		true -> [{Username,Points} | T] = Current, CurrentUserPoints = maps:get(Username,LeaderBoard), 
				if
					Points > CurrentUserPoints -> update_points(maps:put(Username,CurrentUserPoints,LeaderBoard),T);
					true -> update_points(LeaderBoard,T)
				end 
	end.

start()-> register(?MODULE,spawn(fun()-> game_starter(#{}) end )).