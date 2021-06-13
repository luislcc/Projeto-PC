-module(server).
-export([start/1,stop/0]).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initialize

start(Port) -> register(?MODULE,spawn(fun()->server(Port) end)).

stop() -> ?MODULE!{stop}.


server(Port)->
	{ok,LSock} =gen_tcp:listen(Port,[binary,{packet,line},{reuseaddr,true}]),
	login_manager:start(),
	queue_manager:start(),
	
	spawn_link(fun()->acceptor(Port,LSock) end),
	receive
		{stop} -> login_manager:stop(), queue_manager:stop(), ok
	end.

%initialize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%acceptor

acceptor(Port,LSock)->
	{ok,Sock} = gen_tcp:accept(LSock),
	spawn(fun()->acceptor(Port,LSock) end),
	logger(Sock).

%acceptor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%logger
logger(Sock)->
	receive
		{tcp,_,Data} -> parserLogger(Data,Sock);
		
		{valid_login, Username, login_manager} ->
				gen_tcp:send(Sock,list_to_binary("valid login\n")),
				user(Sock,Username);

		{invalid_login,login_manager} -> 
				gen_tcp:send(Sock,list_to_binary("invalid login\n")),
				logger(Sock);

		{valid_create,login_manager} -> 
				gen_tcp:send(Sock,list_to_binary("created account\n")),
				logger(Sock);

		{user_exists,login_manager} ->
				gen_tcp:send(Sock,list_to_binary("user already exists\n")),
				logger(Sock);

		{valid_close,login_manager} ->
				gen_tcp:send(Sock,list_to_binary("valid close\n")),
				logger(Sock);

		{invalid_close,login_manager} ->
				gen_tcp:send(Sock,list_to_binary("invalid close\n")),
				logger(Sock);
		
		{online,Online_users,login_manager} ->
				X = string:join(Online_users," "),
				Y = X,
				gen_tcp:send(Sock,list_to_binary(["online now : ",Y, "\n"])),
				logger(Sock)
	end.


parserLogger(Data,Sock) ->
	case string:split(string:trim(binary_to_list(Data))," ",all) of
		["login",Username,Password] -> 
				login_manager ! {login,self(),Username,Password}, logger(Sock);

		["create",Username,Password] ->
				login_manager ! {create_account,self(),Username,Password}, logger(Sock);

		["close",Username,Password] ->
				login_manager ! {close_account,self(),Username,Password}, logger(Sock);
		
		["online"] ->
				login_manager ! {online,self()}, logger(Sock);

		_ -> logger(Sock)
	end.
%logger
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%










%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%User

user(Sock,Username)->
	receive
		{tcp,_,Data} -> userParser(Data, Sock,Username);
		{joined,game} -> gen_tcp:send(Sock,list_to_binary("game started\n")),player(Sock,Username);
		{enqueued,Position,queue_manager} -> gen_tcp:send(Sock,list_to_binary(["enqueued in : ",integer_to_list(Position),"\n"])),enqueued(Sock,Username);
		{valid_logout,login_manager} -> gen_tcp:send(Sock,list_to_binary("logged out\n")), logger(Sock);
		{online,Online_users,login_manager} -> X = string:join(Online_users," "), Y = X, gen_tcp:send(Sock,list_to_binary(["online now : ",Y, "\n"])), user(Sock,Username)
	end.


userParser(Data, Sock,Username) ->
	case string:split(string:trim(binary_to_list(Data))," ",all) of	
			["join"] -> queue_manager ! {join,self(),Username}, user(Sock,Username);
			["online"] -> login_manager ! {online,self()}, user(Sock,Username);
			["logout"] -> login_manager ! {logout,self(),Username}, user(Sock,Username);
			_ -> user(Sock,Username)
	end.

%User
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Enqueuer

enqueued(Sock,Username) ->
	receive
		{tcp,_,Data} -> enqueuedParser(Data,Sock,Username);
		{joined,game} -> gen_tcp:send(Sock,list_to_binary("game started\n")),player(Sock,Username);
		{leftQueue,queue_manager} -> gen_tcp:send(Sock,list_to_binary("left queue\n")),user(Sock,Username);
		{enqueued,Position,queue_manager} -> gen_tcp:send(Sock,list_to_binary(["enqueued in : ",integer_to_list(Position),"\n"])),enqueued(Sock,Username)	
	end.


enqueuedParser(Data,Sock,Username) ->
	case string:split(string:trim(binary_to_list(Data))," ",all) of	
			["leave"] -> queue_manager ! {leave,self(),Username}, enqueued(Sock,Username);
			_ -> user(Sock,Username)
	end.

%Enqueuer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Player

player(Sock,Username) ->
	receive
		{tcp,_,Data} -> playerParser(Data,Sock,Username);
		{update,NextState,Leaderboard,game} -> sendState(Sock,NextState,Leaderboard),player(Sock,Username);
		{left,game} -> gen_tcp:send(Sock,list_to_binary("left game\n")),user(Sock,Username);
		{dead,game} -> gen_tcp:send(Sock,list_to_binary("lost!\n")),user(Sock,Username)
	end.


playerParser(Data,Sock,Username) ->
	case string:split(string:trim(binary_to_list(Data))," ",all) of	
			["leave"] -> game!{leave,self()}, player(Sock,Username);   
			["w_p"]   -> game!{w_press,self()}, player(Sock,Username);   
			["w_r"]   -> game!{w_release,self()}, player(Sock,Username);   
			["a_p"]   -> game!{a_press,self()}, player(Sock,Username);
			["a_r"]   -> game!{a_release,self()}, player(Sock,Username);
			["d_p"]   -> game!{d_press,self()}, player(Sock,Username);
			["d_r"]   -> game!{d_release,self()}, player(Sock,Username);
			_ -> player(Sock,Username)
	end.

%Player
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ParseState

sendState(Sock,State,Leaderboard) ->
	gen_tcp:send(Sock,list_to_binary(["update\n",state_to_list(State),integer_to_list(maps:size(Leaderboard)),"\n",leaderboard_to_list(Leaderboard)])).


leaderboard_to_list(Leaderboard) ->
	ListLeaderboard = maps:to_list(Leaderboard),
	K = [[Username,"\n",integer_to_list(Points),"\n"] || {Username,Points} <- ListLeaderboard],
	K.

state_to_list(State) ->
	{Map,Players,Creatures} = State,
	{Width,Height,Obstacle_List} = Map,
	Map_String = [integer_to_list(Width), "\n", integer_to_list(Height), "\n", integer_to_list(length(Obstacle_List)),"\n", obstacle_to_list(Obstacle_List)],
	Player_String = [integer_to_list(maps:size(Players)),"\n",player_to_list(Players)],
	Creature_String = [integer_to_list(length(Creatures)),"\n",creature_to_list(Creatures)],
	[Map_String,Player_String,Creature_String].

obstacle_to_list(Obstacle_List)->             
	[[float_to_list(X),"\n",float_to_list(Y),"\n",float_to_list(R),"\n"] || {{X,Y},R} <- Obstacle_List]. 

player_to_list(Players)->
	L = maps:to_list(Players),
	[[pid_to_list(P),"\n",integer_to_list(check_self(P)),"\n",
	float_to_list(element(1,maps:get(pos,M))),"\n",float_to_list(element(2,maps:get(pos,M))),
	"\n",float_to_list(maps:get(radius,M)),"\n",float_to_list( maps:get(direction,M)),"\n",integer_to_list(maps:get(points,M)),
	"\n",maps:get(username,M),"\n",float_to_list( maps:get(energy,M)),"\n" ] || {P,M} <- L ].

check_self(Pid) ->
	S = self(),
	if
		Pid == S -> 1;
		true -> 0
	end.

creature_to_list(Creatures)->
	[[integer_to_list(maps:get(type,M)),"\n",float_to_list(element(1,maps:get(pos,M))),"\n",float_to_list(element(2,maps:get(pos,M))),"\n",float_to_list(maps:get(radius,M)),"\n",float_to_list(maps:get(direction,M)),"\n"] || M <- Creatures].

%ParseState
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

