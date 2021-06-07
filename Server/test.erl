-module(test).
-export([start/1]).

server(Port)->
	{ok,LSock} =gen_tcp:listen(Port,[binary,{packet,line},{reuseaddr,true}]),
	
	spawn_link(fun()->acceptor(Port,LSock) end),
	receive
		stop -> ok
	end.

user_manager(Sock)->
	receive
		{tcp,_,Data} ->
			case string:split(string:trim(binary_to_list(Data))," ",all) of
				
				["update"] -> 
							gen_tcp:send(Sock,list_to_binary([integer_to_list(1000),"\n", integer_to_list(600), "\n", integer_to_list(3), "\n",["ola","\n","bruh","\n"]])),
							user_manager(Sock)

			end
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