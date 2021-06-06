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









user(Sock,Username)->
	receive
		{tcp,_,Data} ->
			case string:split(string:trim(binary_to_list(Data))," ",all) of	
					["logout"] ->
						 	login_manager ! {create_account,self(),Username},
						 	user(Sock,Username);
				
					["online"] ->
							login_manager ! {online,self()},
							user(Sock,Username);
				end;

		
		{valid_logout,login_manager} ->
					gen_tcp:send(Sock,list_to_binary("valid logout\n")),
					user_manager(Sock);
			
		{online,Online_users,login_manager} ->
					X = string:join(Online_users," "),
					Y = X ++ "\n",
					gen_tcp:send(Sock,list_to_binary(Y)),
					user_manager(Sock)
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
							gen_tcp:send(Sock,list_to_binary("valid login\n")),	user(Sock,Username);

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