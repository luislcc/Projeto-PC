-module(server).
-export([start/1,stop/0]).

server(Port)->
	{ok,LSock} =gen_tcp:listen(Port,[binary,{packet,line},{reuseaddr,true}]),
	login_manager:start(),
	game_manager:start(),
	
	spawn_link(fun()->acceptor(Port,LSock) end),
	receive
		{stop} -> login_manager:stop(),ok
	end.


%State = {{width,height,obstacle_list},{Pid => {pos =>},List}

state_to_list(State) ->
	{Map,Players,Creatures} = State,
	{Width,Height,Obstacle_List} = Map,
	Map_String = [integer_to_list(Width), "\n", integer_to_list(Height), "\n", integer_to_list(length(Obstacle_List)),"\n", obstacle_to_list(Obstacle_List)],
	%io:format("MAP CONSTRUIDO: ~p~n",[Map_String]),
	Player_String = [integer_to_list(maps:size(Players)),"\n",player_to_list(Players)],
	%io:format("PLAYERS CONSTRUIDOS ~p~n",[Player_String]),
	Creature_String = [integer_to_list(length(Creatures)),"\n",creature_to_list(Creatures)],
	%io:format("Creatures CONSTRUIDAS ~p~n",[Creature_String]),
	[Map_String,Player_String,Creature_String].

obstacle_to_list(Obstacle_List)->             
	[[float_to_list(X),"\n",float_to_list(Y),"\n",float_to_list(R),"\n"] || {{X,Y},R} <- Obstacle_List]. 

player_to_list(Players)->
	L = maps:to_list(Players),
	[[pid_to_list(P),"\n",float_to_list(element(1,maps:get(pos,M))),"\n",float_to_list(element(2,maps:get(pos,M))),"\n",integer_to_list(maps:get(radius,M)),"\n",float_to_list( maps:get(direction,M)),"\n"] || {P,M} <- L ].

creature_to_list(Creatures)->
	[[integer_to_list(maps:get(type,M)),"\n",float_to_list(element(1,maps:get(pos,M))),"\n",float_to_list(element(2,maps:get(pos,M))),"\n",integer_to_list(maps:get(radius,M)),"\n",float_to_list(maps:get(direction,M)),"\n"] || M <- Creatures].


user(Sock,Username)->
	receive
		{tcp,_,Data} ->
			case string:split(string:trim(binary_to_list(Data))," ",all) of	
					["logout"] ->
						 	login_manager ! {create_account,self(),Username},
						 	user(Sock,Username);

					["join"] ->
							game_manager ! {join,self(),Username},
							user(Sock,Username);

					["update"] ->
							game_manager ! {update,self()},
							user(Sock,Username);
				
					["online"] ->
							login_manager ! {online,self()},
							user(Sock,Username);

					_ -> user(Sock,Username)
				end;

		{update,State,game_manager} -> gen_tcp:send(Sock,list_to_binary(["update\n",state_to_list(State)])),user(Sock,Username);

		{joined_game,game} -> gen_tcp:send(Sock,list_to_binary("game started\n")),user(Sock,Username);

		{left_game,game_manager} -> gen_tcp:send(Sock,list_to_binary("left game\n")),user(Sock,Username);

		{dead,game_manager} -> gen_tcp:send(Sock,list_to_binary(["dead\n",pid_to_list(self()),"\n"])),user(Sock,Username);

		{enqueued,game_manager} -> gen_tcp:send(Sock,list_to_binary("enqueued\n")),user(Sock,Username);

		{left_queue,game_manager} -> gen_tcp:send(Sock,list_to_binary("left queue\n")),user(Sock,Username);

		{valid_logout,login_manager} ->
					gen_tcp:send(Sock,list_to_binary("logged out\n")),
					user_manager(Sock);
			
		{online,Online_users,login_manager} ->
					X = string:join(Online_users," "),
					Y = X ++ "\n",
					gen_tcp:send(Sock,list_to_binary(Y)),
					user_manager(Sock);

		_ -> user(Sock,Username)
	end.


user_manager(Sock)->
	receive
		{tcp,_,Data} ->
			case string:split(string:trim(binary_to_list(Data))," ",all) of
				
				["login",Username,Password] -> 
							login_manager ! {login,self(),Username,Password},
							user_manager(Sock);

				["create",Username,Password] ->
							login_manager ! {create_account,self(),Username,Password},
							user_manager(Sock);


				["close",Username,Password] ->
							login_manager ! {close_account,self(),Username,Password},
							user_manager(Sock);


				["online"] ->
						login_manager ! {online,self()},
						user_manager(Sock);

				_ -> user_manager(Sock)

		end;


		
		{valid_login, Username, login_manager} ->
							gen_tcp:send(Sock,list_to_binary("valid login\n")),
							user(Sock,Username);

		{invalid_login,login_manager} -> 
						gen_tcp:send(Sock,list_to_binary("invalid login\n")),
						user_manager(Sock);

		{valid_create,login_manager} -> 
						gen_tcp:send(Sock,list_to_binary("created account\n")),
						user_manager(Sock);

		{user_exists,login_manager} ->
					gen_tcp:send(Sock,list_to_binary("user already exists\n")),
					user_manager(Sock);

		{valid_close,login_manager} ->
					gen_tcp:send(Sock,list_to_binary("valid close\n")),
					user_manager(Sock);

		{invalid_close,login_manager} ->
					gen_tcp:send(Sock,list_to_binary("invalid close\n")),
					user_manager(Sock);
		
		{online,Online_users,login_manager} ->
					X = string:join(Online_users," "),
					Y = X ++ "\n",
					gen_tcp:send(Sock,list_to_binary(Y)),
					user_manager(Sock)
	end.

acceptor(Port,LSock)->
	{ok,Sock} = gen_tcp:accept(LSock),
	spawn(fun()->acceptor(Port,LSock) end),
	user_manager(Sock).
	

	%Room = spawn(fun()->room([]) end),
	%spawn(fun() -> acceptor(Room,LSock) end),
	%receive
	%	{stop,bruh} -> ok
	%end.




start(Port) -> register(?MODULE,spawn(fun()->server(Port) end)).

stop() -> ?MODULE!{stop}.