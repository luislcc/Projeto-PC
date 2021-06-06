-module(game_mamager).
-export([start/1,stop/0]).


initialize()->
	register(game,spawn_link(fun()-> game_instance() end)),
	loop([],queue:new()).


loop(Players,Queue)->
	receive 
		{join,Pid} when (not queue:is_empty(Queue))-> avisar jogador, loop(Players,queue:snoc(Queue,Pid));

		{join,Pid} when length(Players) < 3 ->  avisar jogador, loop([Pid | Players],Queue);
		
		{join,Pid} when length(Players) >= 3 ->  avisar jogador, loop(Players,queue:snoc(Queue,Pid));

		{leave,Pid} when (not queue:is_empty(Queue)) -> avisar jogador, 
															loop([queue:get(Queue) | (Players -- [Pid])], queue:drop(Queue));
		
		{leave,Pid} -> loop(Players -- [Pid],Queue);

	end.



game_instance() ->
	calcular game state,
	if 
	 	(PlayerNum < 1) -> T = infinity; 
	 	true -> T = 0 
	end,
	
	receive 
		player input

		player join

		player leave

	after T -> game_instance()
	end.



% -module(test).
% -export([init/0,tester/1]).

% tester(Guys)->
%     if Guys < 3 -> T = infinity;
%         true -> T = 0 end,
%     receive
%         hey -> io:format("Hello ~n"), tester(Guys+1)

%     after T -> io:format("loop"), tester(Guys)
%     end. 


init() -> register(?MODULE, spawn(fun() -> tester(0) end)). 






start()-> register(?MODULE,spawn(fun()-> initialize() end )).

stop()-> ?MODULE! stop